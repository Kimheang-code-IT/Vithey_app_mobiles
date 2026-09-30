import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/settings/security/security_settings_controller.dart';

class SecuritySettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SecuritySettingsController>(() => SecuritySettingsController(Get.find<LocalStorageService>()));
  }
}
