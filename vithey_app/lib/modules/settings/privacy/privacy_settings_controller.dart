import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/settings_models.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';

class PrivacySettingsController extends GetxController {
  PrivacySettingsController(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  final privacy = const PrivacySettings().obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrivacySettings();
  }

  Future<void> loadPrivacySettings() async {
    isLoading.value = true;
    try {
      privacy.value = await _settingsRepository.loadPrivacySettings();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleProfileVisibility(bool value) => _toggle((s) => s.copyWith(profileVisible: value), value);

  Future<void> toggleDataSharing(bool value) => _toggle((s) => s.copyWith(dataSharing: value), value);

  Future<void> toggleActivityTracking(bool value) => _toggle((s) => s.copyWith(activityTracking: value), value);

  Future<void> _toggle(PrivacySettings Function(PrivacySettings) updater, bool value) async {
    final previous = privacy.value;
    final updated = updater(previous);
    privacy.value = updated;
    try {
      await _settingsRepository.savePrivacySettings(updated);
    } catch (_) {
      privacy.value = previous;
      Get.snackbar('Vithey', 'Failed to save preference');
    }
  }

  Future<void> openPrivacyPractices() async {
    await Get.toNamed(AppRoutes.settingsPrivacyPractices);
  }
}
