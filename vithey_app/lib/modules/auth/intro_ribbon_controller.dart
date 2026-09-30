import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/language/select_language_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';
import 'package:aub_connect_app/modules/auth/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Single continuum for Language → Onboarding×3 → Sign In → Sign Up.
/// Forward (index↑) slides left; backward (index↓) slides right.
/// Navigation is **button-driven only** (PageView swipe is disabled).
class IntroRibbonController extends GetxController {
  IntroRibbonController(
    this._localStorage, {
    this.initialPage = pageLanguage,
  });

  final LocalStorageService _localStorage;
  final int initialPage;

  static const pageLanguage = 0;
  static const pageOnboarding1 = 1;
  static const pageOnboarding2 = 2;
  static const pageOnboarding3 = 3;
  static const pageSignIn = 4;
  static const pageSignUp = 5;
  static const pageCount = 6;

  late final pageController = PageController(initialPage: initialPage);
  late final currentPage = initialPage.obs;
  final isBusy = false.obs;
  final selectedLanguage = AppLanguageOption.en.obs;

  final onboardingSlides = const [
    OnboardingSlide(
      title: 'Connect with Your Campus Community',
      description:
          'Discover posts, connect with friends, and stay updated.',
      imageAsset: 'assets/images/onboarding/onboarding_1.png',
    ),
    OnboardingSlide(
      title: 'Jobs & Career Growth',
      description:
          'Discover job posts, apply with your CV, and connect with opportunities on campus.',
      imageAsset: 'assets/images/onboarding/onboarding_2.png',
    ),
    OnboardingSlide(
      title: 'Finance, Chat & AI Support',
      description:
          'Track tuition payments, chat privately, and get AI help for study and career.',
      imageAsset: 'assets/images/onboarding/onboarding_3.png',
    ),
  ];

  WaveRibbonProfile profileFor(int page) => WaveRibbon.all[page.clamp(0, 5)];

  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
    _syncAuthIndex(initialPage);
  }

  Future<void> _loadLanguage() async {
    final code = await _localStorage.readLanguage();
    if (isClosed) return;
    selectedLanguage.value =
        code == 'km' ? AppLanguageOption.km : AppLanguageOption.en;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
    _syncAuthIndex(index);
  }

  void _syncAuthIndex(int index) {
    if (!Get.isRegistered<AuthController>()) return;
    final auth = Get.find<AuthController>();
    if (index != pageSignIn && auth.showForgotPassword.value) {
      auth.closeForgotPassword();
    }
    if (index == pageSignIn) {
      auth.authPageIndex.value = 0;
    } else if (index == pageSignUp) {
      auth.authPageIndex.value = 1;
    }
  }

  Future<void> goTo(int index, {bool animate = true}) async {
    final target = index.clamp(0, pageCount - 1);
    if (currentPage.value == target &&
        (pageController.page?.round() ?? currentPage.value) == target) {
      return;
    }
    if (!animate) {
      pageController.jumpToPage(target);
      currentPage.value = target;
      _syncAuthIndex(target);
      return;
    }
    isBusy.value = true;
    await pageController.animateToPage(
      target,
      duration: IntroMorph.panelDuration,
      curve: Curves.easeInOut,
    );
    if (!isClosed) isBusy.value = false;
  }

  void selectLanguage(AppLanguageOption option) {
    if (isBusy.value) return;
    selectedLanguage.value = option;
  }

  Future<void> languageContinue() async {
    if (isBusy.value) return;
    isBusy.value = true;
    final code = switch (selectedLanguage.value) {
      AppLanguageOption.en => 'en',
      AppLanguageOption.km => 'km',
    };
    try {
      await _localStorage.saveLanguage(code);
      await _localStorage.setLanguageSelected(true);
      final onboardingDone = await _localStorage.isOnboardingCompleted();
      if (onboardingDone) {
        isBusy.value = false;
        await goTo(pageSignIn);
        return;
      }
    } catch (_) {}
    isBusy.value = false;
    await goTo(pageOnboarding1);
  }

  Future<void> onboardingNext() async {
    if (isBusy.value) return;
    final page = currentPage.value;
    if (page >= pageOnboarding1 && page < pageOnboarding3) {
      await goTo(page + 1);
      return;
    }
    if (page == pageOnboarding3) {
      await finishOnboarding();
    }
  }

  Future<void> onboardingBack() async {
    if (isBusy.value) return;
    final page = currentPage.value;
    if (page > pageLanguage) {
      await goTo(page - 1);
    }
  }

  Future<void> skipOnboarding() async {
    // Screen handles chrome exit + finish when Skip is pressed from overlay.
    await finishOnboarding();
  }

  Future<void> finishOnboarding() async {
    if (isBusy.value) return;
    await _localStorage.setOnboardingCompleted(true);
    await goTo(pageSignIn);
  }

  Future<void> authBack() async {
    if (isBusy.value) return;
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }
    await _localStorage.setOnboardingCompleted(false);
    await goTo(pageOnboarding3);
  }

  void showSignIn() => goTo(pageSignIn);
  void showSignUp() => goTo(pageSignUp);

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
