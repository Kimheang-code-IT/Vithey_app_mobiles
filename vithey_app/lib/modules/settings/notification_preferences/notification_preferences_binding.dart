import 'package:get/get.dart';
import 'package:aub_connect_app/data/push/fcm_service.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/notification_preferences_controller.dart';

class NotificationPreferencesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationPreferencesController>(
      () => NotificationPreferencesController(
        Get.find<SettingsRepository>(),
        Get.find<FcmService>(),
      ),
    );
  }
}
