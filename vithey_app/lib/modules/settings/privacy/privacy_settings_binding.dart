import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/modules/settings/privacy/privacy_settings_controller.dart';

class PrivacySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PrivacySettingsController>(() => PrivacySettingsController(Get.find<SettingsRepository>()));
  }
}
