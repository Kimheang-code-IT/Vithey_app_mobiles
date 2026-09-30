import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/auth/startup/startup_controller.dart';

class StartupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StartupController>(
      () => StartupController(Get.find<LocalStorageService>()),
      fenix: true,
    );
  }
}
