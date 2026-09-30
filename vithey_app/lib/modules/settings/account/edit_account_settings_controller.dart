import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/settings/account/widgets/account_section_sheets.dart';

/// Draft editor for private personal account fields (sheet-based).
class EditAccountSettingsController extends GetxController {
  EditAccountSettingsController(this._profileRepository);

  final ProfileRepository _profileRepository;

  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isSaving = false.obs;
  final isUploadingAvatar = false.obs;

  final fullName = ''.obs;
  final email = ''.obs;
  final phone = ''.obs;
  final gender = ''.obs;
  final location = ''.obs;
  final dateOfBirth = Rxn<DateTime>();
  final avatarUrl = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final loaded =
          await _profileRepository.getProfile(ProfileRepository.currentUserId);
      profile.value = loaded;
      _bindDraft(loaded);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _bindDraft(UserProfileModel loaded) {
    fullName.value = loaded.fullName;
    email.value = loaded.email ?? '';
    phone.value = loaded.phone ?? '';
    gender.value = loaded.gender ?? '';
    location.value = loaded.location ?? '';
    dateOfBirth.value = loaded.dateOfBirth;
    avatarUrl.value = loaded.avatarUrl;
  }

  Future<void> changeAvatar() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
    );
    if (file == null) return;

    isUploadingAvatar.value = true;
    try {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      avatarUrl.value = file.path;
      Get.snackbar('Vithey', 'Avatar updated');
    } catch (e) {
      Get.snackbar(
        'Vithey',
        'Avatar upload failed',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  void onEmailTap() {
    changeEmailWithGoogle();
  }

  Future<void> changeEmailWithGoogle() async {
    if (!Get.isRegistered<AuthController>()) {
      Get.put(
        AuthController(Get.find<AuthRepository>()),
        permanent: false,
      );
    }
    final auth = Get.find<AuthController>();
    final newEmail = await auth.beginGoogleEmailChange();
    if (newEmail == null || newEmail.trim().isEmpty) return;
    email.value = newEmail.trim();
    Get.snackbar('Vithey', 'Email updated from Google — tap Save to apply');
  }

  Future<void> editFullName(BuildContext context) async {
    final result = await showAccountTextSheet(
      context,
      title: 'Edit full name',
      label: 'Full name',
      existing: fullName.value,
      required: true,
    );
    if (result == null || result.deleted) return;
    fullName.value = result.value ?? '';
  }

  Future<void> editPhone(BuildContext context) async {
    final result = await showAccountTextSheet(
      context,
      title: 'Edit phone',
      label: 'Phone',
      existing: phone.value,
      keyboardType: TextInputType.phone,
    );
    if (result == null || result.deleted) return;
    phone.value = result.value ?? '';
  }

  Future<void> editGender(BuildContext context) async {
    final result = await showAccountTextSheet(
      context,
      title: 'Edit gender',
      label: 'Gender',
      existing: gender.value,
    );
    if (result == null || result.deleted) return;
    gender.value = result.value ?? '';
  }

  Future<void> editLocation(BuildContext context) async {
    final result = await showAccountTextSheet(
      context,
      title: 'Edit location',
      label: 'Location',
      existing: location.value,
    );
    if (result == null || result.deleted) return;
    location.value = result.value ?? '';
  }

  Future<void> editDateOfBirth(BuildContext context) async {
    final result = await showAccountDateOfBirthSheet(
      context,
      existing: dateOfBirth.value,
    );
    if (result == null || result.deleted) return;
    dateOfBirth.value = result.value;
  }

  Future<void> save() async {
    final name = fullName.value.trim();
    if (name.isEmpty) {
      Get.snackbar('Vithey', 'Full name is required');
      return;
    }

    isSaving.value = true;
    try {
      final updated = await _profileRepository.updateProfile(
        fullName: name,
        email: email.value.trim(),
        phone: phone.value.trim(),
        location: location.value.trim(),
        gender: gender.value.trim(),
        avatarUrl: avatarUrl.value,
        dateOfBirth: dateOfBirth.value,
        updateDateOfBirth: true,
      );

      profile.value = updated;
      isSaving.value = false;
      if (Get.previousRoute == AppRoutes.settingsAccount) {
        Get.back(result: true);
      } else {
        Get.offNamed(AppRoutes.settingsAccount);
      }
      Get.snackbar('Vithey', 'Account updated');
    } catch (e) {
      Get.snackbar('Vithey', 'Failed to save account');
    } finally {
      if (isSaving.value) {
        isSaving.value = false;
      }
    }
  }

  void cancel() => Get.back(result: false);
}
