import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/modules/home/notification/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
        () => NotificationController(Get.find<NotificationRepository>()));
  }
}
