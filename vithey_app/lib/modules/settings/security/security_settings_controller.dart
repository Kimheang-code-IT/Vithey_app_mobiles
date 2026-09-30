import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';

class SecuritySettingsController extends GetxController {
  SecuritySettingsController(this._localStorage);

  final LocalStorageService _localStorage;

  final twoFactorEnabled = false.obs;
  final biometricEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBiometric();
  }

  Future<void> _loadBiometric() async {
    biometricEnabled.value = await _localStorage.readBiometricEnabled();
  }

  void openChangePassword() => Get.toNamed(AppRoutes.settingsChangePassword);

  void toggleTwoFactor(bool value) {
    // Backend 2FA is not available yet — keep the switch off.
    twoFactorEnabled.value = false;
    if (value) {
      Get.snackbar('Vithey', 'Two-factor authentication is coming soon');
    }
  }

  Future<void> toggleBiometric(bool value) async {
    if (value && !biometricAvailable) {
      biometricEnabled.value = false;
      Get.snackbar('Vithey', 'Biometric login is coming soon');
      return;
    }
    biometricEnabled.value = value;
    await _localStorage.saveBiometricEnabled(value);
  }

  bool get twoFactorAvailable => false;
  bool get biometricAvailable => false;
}
