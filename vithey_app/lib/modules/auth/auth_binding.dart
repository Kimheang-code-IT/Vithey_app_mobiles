import 'package:get/get.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';

/// Binding for auth sub-flows that are not the intro ribbon (forgot password,
/// Google chooser). The continuum uses [IntroRibbonBinding] instead.
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AuthController>()) {
      Get.lazyPut<AuthController>(
        () => AuthController(Get.find<AuthRepository>()),
        fenix: true,
      );
    }
  }
}
