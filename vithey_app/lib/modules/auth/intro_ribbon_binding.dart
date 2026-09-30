import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/repositories/auth_repository.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/intro_ribbon_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';

class IntroRibbonBinding extends Bindings {
  IntroRibbonBinding({this.initialPage});

  /// Override initial page; otherwise read [IntroMorph] / route defaults.
  final int? initialPage;

  @override
  void dependencies() {
    final start = initialPage ??
        (IntroMorph.startOnSignUp
            ? IntroRibbonController.pageSignUp
            : IntroMorph.initialOnboardingPage > 0
                ? IntroRibbonController.pageOnboarding1 +
                    IntroMorph.initialOnboardingPage.clamp(0, 2)
                : IntroMorph.fromAuth
                    ? IntroRibbonController.pageOnboarding3
                    : IntroMorph.fromLanguage
                        ? IntroRibbonController.pageOnboarding1
                        : null);
    IntroMorph.clear();

    if (Get.isRegistered<IntroRibbonController>()) {
      Get.delete<IntroRibbonController>(force: true);
    }
    Get.put(
      IntroRibbonController(
        Get.find<LocalStorageService>(),
        initialPage: start ?? IntroRibbonController.pageLanguage,
      ),
    );

    if (Get.isRegistered<AuthController>()) {
      Get.delete<AuthController>(force: true);
    }
    Get.put(AuthController(Get.find<AuthRepository>()));
  }
}
