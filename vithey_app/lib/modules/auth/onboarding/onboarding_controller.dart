import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/modules/auth/onboarding/intro_morph.dart';

class OnboardingSlide {
  const OnboardingSlide({
    required this.title,
    required this.description,
    this.imageAsset,
  });

  final String title;
  final String description;
  final String? imageAsset;
}

class OnboardingController extends GetxController {
  OnboardingController(
    this._localStorage, {
    this.fromLanguage = false,
    this.fromAuth = false,
    this.initialPage = 0,
  });

  final LocalStorageService _localStorage;
  final bool fromLanguage;
  final bool fromAuth;
  final int initialPage;

  late final pageController = PageController(initialPage: initialPage);
  late final currentPage = initialPage.obs;

  final contentOpacity = 1.0.obs;
  final isBusy = false.obs;

  static const totalPages = 3;
  static const introDotCount = 4;

  final slides = const [
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

  @override
  void onInit() {
    super.onInit();
    if (fromLanguage || fromAuth) {
      contentOpacity.value = 0;
      _fadeContentIn();
    }
  }

  Future<void> _fadeContentIn() async {
    await IntroMorph.run(IntroMorph.duration, (t) {
      if (isClosed) return;
      contentOpacity.value = t;
    });
    if (!isClosed) contentOpacity.value = 1;
  }

  void onPageChanged(int index) => currentPage.value = index;

  void next() {
    if (isBusy.value) return;
    if (currentPage.value < totalPages - 1) {
      pageController.nextPage(
        duration: IntroMorph.panelDuration,
        curve: Curves.easeInOut,
      );
    } else {
      finish();
    }
  }

  Future<void> back() async {
    if (isBusy.value) return;
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: IntroMorph.panelDuration,
        curve: Curves.easeInOut,
      );
      return;
    }

    isBusy.value = true;
    await _localStorage.setOnboardingCompleted(false);
    IntroMorph.fromOnboarding = true;
    Get.offAllNamed(AppRoutes.selectLanguage);
  }

  void skip() => finish();

  Future<void> finish() async {
    if (isBusy.value) return;
    isBusy.value = true;
    await _localStorage.setOnboardingCompleted(true);
    IntroMorph.fadeContentIn = true;
    Get.offAllNamed(AppRoutes.login);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
