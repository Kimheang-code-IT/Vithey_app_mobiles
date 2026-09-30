import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/profile_repository.dart';

class AccountSettingsController extends GetxController {
  AccountSettingsController(this._profileRepository);

  final ProfileRepository _profileRepository;

  final profile = Rxn<UserProfileModel>();
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final isUploadingAvatar = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAccount();
  }

  Future<void> loadAccount() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      profile.value =
          await _profileRepository.getProfile(ProfileRepository.currentUserId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  String formatDateOfBirth(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM dd, yyyy').format(date);
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
      profile.value = profile.value?.copyWith(avatarUrl: file.path);
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

  Future<void> openEditInfo() async {
    final updated = await Get.toNamed(AppRoutes.settingsEditAccount);
    if (updated == true) {
      await loadAccount();
    }
  }
}
