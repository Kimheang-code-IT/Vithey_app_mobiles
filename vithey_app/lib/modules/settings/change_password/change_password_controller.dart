import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';

class ChangePasswordController extends GetxController {
  ChangePasswordController(this._authRepository);

  final AuthRepository _authRepository;

  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  final isLoading = false.obs;
  final showCurrent = false.obs;
  final showNew = false.obs;
  final showConfirm = false.obs;

  bool get hasMinLength => newPassword.text.length >= 8;
  bool get hasUppercase => RegExp(r'[A-Z]').hasMatch(newPassword.text);
  bool get hasNumber => RegExp(r'[0-9]').hasMatch(newPassword.text);
  bool get hasSpecial => RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassword.text);
  bool get passwordsMatch => newPassword.text.isNotEmpty && newPassword.text == confirmPassword.text;

  bool get canSubmit =>
      currentPassword.text.isNotEmpty &&
      hasMinLength &&
      hasUppercase &&
      hasNumber &&
      hasSpecial &&
      passwordsMatch &&
      !isLoading.value;

  @override
  void onInit() {
    super.onInit();
    for (final c in [currentPassword, newPassword, confirmPassword]) {
      c.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() => update();

  @override
  void onClose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmPassword.dispose();
    super.onClose();
  }

  Future<void> updatePassword() async {
    if (!canSubmit) return;
    isLoading.value = true;
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword.text,
        newPassword: newPassword.text,
      );
      currentPassword.clear();
      newPassword.clear();
      confirmPassword.clear();
      Get.back();
      Get.snackbar('Vithey', 'Password updated successfully');
    } catch (e) {
      currentPassword.clear();
      Get.snackbar('Vithey', e.toString().replaceFirst('AuthServiceException: ', ''));
    } finally {
      isLoading.value = false;
    }
  }
}
