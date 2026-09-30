import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/theme/app_theme.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/local/search_recent_store.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/modules/settings/widgets/language_picker_sheet.dart';

class SettingsController extends GetxController {
  SettingsController(this._settingsRepository, this._authRepository, this._localStorage);

  final SettingsRepository _settingsRepository;
  final AuthRepository _authRepository;
  final LocalStorageService _localStorage;

  final isDarkMode = false.obs;
  final languageCode = 'en'.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  Future<void> loadSettings() async {
    isLoading.value = true;
    try {
      final settings = await _settingsRepository.loadSettings();
      isDarkMode.value = settings.themeMode == 'dark';
      languageCode.value = settings.language;
    } finally {
      isLoading.value = false;
    }
  }

  String get languageLabel {
    switch (languageCode.value) {
      case 'km':
        return 'Khmer';
      default:
        return 'English (US)';
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    final mode = value ? ThemeMode.dark : ThemeMode.light;
    Get.changeThemeMode(mode);
    await _settingsRepository.saveThemeMode(AppTheme.toStorage(mode));
  }

  void openLanguagePicker() {
    // Clear leftover GetX snackbar overlays so they don't steal dismissals.
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    final ctx = Get.context!;
    final bg = ctx.appColors.inputFill;
    Get.bottomSheet(
      LanguagePickerSheet(
        selectedCode: languageCode.value,
        onSelect: _selectLanguage,
      ),
      backgroundColor: bg,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(VitheyRadii.sheet)),
      ),
    );
  }

  Future<void> _selectLanguage(String code) async {
    languageCode.value = code;
    try {
      await _settingsRepository.saveLanguage(code);
      Get.snackbar('Vithey', 'Language preference saved');
    } catch (_) {
      Get.snackbar('Vithey', 'Could not save language preference');
    }
  }

  Future<void> logout() async {
    final confirmed = await showConfirmDialog(
      context: Get.context!,
      title: 'Logout',
      message: 'Are you sure you want to log out of Vithey?',
      confirmLabel: 'Logout',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;

    try {
      if (Get.isRegistered<FcmService>()) {
        await Get.find<FcmService>().unregisterToken();
      }
      if (Get.isRegistered<NotificationRepository>()) {
        Get.find<NotificationRepository>().clearSession();
      }
      await _authRepository.logout();
      await _localStorage.clearSessionPreferences();
      if (Get.isRegistered<SearchRecentStore>()) {
        await Get.find<SearchRecentStore>().clearAll();
      }
    } catch (_) {}
    // Close any leftover dialogs before wiping the stack.
    while (Get.isDialogOpen ?? false) {
      Get.back<void>();
    }
    Get.offAllNamed(AppRoutes.login);
  }
}
