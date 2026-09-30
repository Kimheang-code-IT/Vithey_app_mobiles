import 'dart:async';

import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';
import 'package:aub_connect_app/core/utils/auth_navigation.dart';

/// Splash intro beats:
/// 1 white → 2 teal falls in → 3 brand in → 4 hold → 5 handoff / navigate
class SplashController extends GetxController with GetTickerProviderStateMixin {
  SplashController(
    this._secureStorage,
    this._localStorage,
    this._featureFlags,
  );

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final FeatureFlags _featureFlags;

  static const whiteHoldDuration = Duration(seconds: 1);
  static const fillDuration = Duration(milliseconds: 1400);
  /// White-50% starts first; teal follows after this delay (same drop curve).
  static const tealDropDelay = Duration(milliseconds: 320);
  static const brandInDuration = Duration(milliseconds: 700);
  static const brandOutDuration = Duration(milliseconds: 450);
  static const brandHoldDuration = Duration(seconds: 1);
  static const handoffDuration = Duration(milliseconds: 1200);
  static const contentRevealDuration = Duration(milliseconds: 500);

  /// White-50% drop (0 → 1), starts first.
  final washFill = 0.0.obs;

  /// Teal drop (0 → 1), overlaps wash; must hit 1 for full cover.
  final tealFill = 0.0.obs;

  /// Logo + title opacity / scale.
  final brandOpacity = 0.0.obs;

  /// 0 = Select Language off-screen below; 1 = fully risen over teal.
  final handoffProgress = 0.0.obs;

  /// Select Language UI — only after the rise completes.
  final languageContentReveal = 0.0.obs;

  /// When true, Select Language is stacked under the splash for the reveal.
  final showLanguageUnderlay = false.obs;

  bool _navigated = false;
  String _nextRoute = AppRoutes.selectLanguage;

  AnimationController? _washCtrl;
  AnimationController? _tealCtrl;
  AnimationController? _brandCtrl;
  AnimationController? _handoffCtrl;
  AnimationController? _contentCtrl;

  @override
  void onInit() {
    super.onInit();
    _runIntro();
  }

  @override
  void onClose() {
    _washCtrl?.dispose();
    _tealCtrl?.dispose();
    _brandCtrl?.dispose();
    _handoffCtrl?.dispose();
    _contentCtrl?.dispose();
    super.onClose();
  }

  Future<void> _runIntro() async {
    final routeFuture = _resolveNextRouteLocal();

    _washCtrl = AnimationController(vsync: this, duration: fillDuration)
      ..addListener(() {
        washFill.value = Curves.easeInOutCubic.transform(_washCtrl!.value);
      });

    _tealCtrl = AnimationController(vsync: this, duration: fillDuration)
      ..addListener(() {
        tealFill.value = Curves.easeInOutCubic.transform(_tealCtrl!.value);
      });

    _brandCtrl = AnimationController(vsync: this, duration: brandInDuration)
      ..addListener(() {
        brandOpacity.value = Curves.easeOutCubic.transform(_brandCtrl!.value);
      });

    try {
      _nextRoute = await routeFuture.timeout(
        whiteHoldDuration + fillDuration + tealDropDelay + brandInDuration,
        onTimeout: () => AppRoutes.selectLanguage,
      );
    } catch (_) {
      _nextRoute = AppRoutes.selectLanguage;
    }

    // Hold full white, then drop top → bottom.
    await Future<void>.delayed(whiteHoldDuration);

    // Dual drop: white-50% first, teal overlaps after a short delay (top → bottom).
    final washFuture = _washCtrl!.forward();
    await Future<void>.delayed(tealDropDelay);
    final tealFuture = _tealCtrl!.forward();
    await Future.wait<void>([washFuture, tealFuture]);
    // Snap teal to full cover (avoids any float rounding gap).
    tealFill.value = 1.0;
    washFill.value = 1.0;

    await _brandCtrl!.forward();
    await Future<void>.delayed(brandHoldDuration);

    if (_nextRoute == AppRoutes.selectLanguage) {
      await _handoffToSelectLanguage();
    } else {
      _goNamed(_nextRoute);
    }
  }

  Future<void> _handoffToSelectLanguage() async {
    // Do NOT Get.put SelectLanguageController here — underlay is preview-only.
    // Binding creates a fresh controller when the real route opens.

    // Fade brand out completely before any rise.
    final brandOut = AnimationController(
      vsync: this,
      duration: brandOutDuration,
    );
    brandOut.addListener(() {
      brandOpacity.value =
          Curves.easeInCubic.transform(1.0 - brandOut.value);
    });
    await brandOut.forward();
    brandOpacity.value = 0;
    brandOut.dispose();

    languageContentReveal.value = 0;
    showLanguageUnderlay.value = true;

    _handoffCtrl = AnimationController(vsync: this, duration: handoffDuration)
      ..addListener(() {
        handoffProgress.value =
            Curves.easeInOutCubic.transform(_handoffCtrl!.value);
      });

    // Rise Select Language background up over the kept teal.
    await _handoffCtrl!.forward();

    // After rise completes, show Select Language content.
    _contentCtrl =
        AnimationController(vsync: this, duration: contentRevealDuration)
          ..addListener(() {
            languageContentReveal.value =
                Curves.easeOutCubic.transform(_contentCtrl!.value);
          });
    await _contentCtrl!.forward();

    _goSelectLanguageSeamless();
  }

  void _goSelectLanguageSeamless() {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(AppRoutes.selectLanguage);
  }

  void _goNamed(String route) {
    if (_navigated) return;
    _navigated = true;
    Get.offAllNamed(route);
  }

  Future<String> _resolveNextRouteLocal() async {
    if (_featureFlags.forceDevFunnel) {
      await _secureStorage.clearTokens();
      await _localStorage.setLanguageSelected(false);
      await _localStorage.setOnboardingCompleted(false);
      await _localStorage.setStartupCompleted(false);
      return AppRoutes.selectLanguage;
    }

    final languageSelected = await _localStorage.isLanguageSelected().timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => false,
    );
    if (!languageSelected) {
      return AppRoutes.selectLanguage;
    }

    if (_featureFlags.forceShowOnboarding) {
      return AppRoutes.onboarding;
    }

    final token = await _secureStorage.readAccessToken().timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => null,
    );
    if (token != null && token.startsWith('mock')) {
      unawaited(_secureStorage.clearTokens());
    }

    final hasToken =
        token != null && token.isNotEmpty && !token.startsWith('mock');
    final onboardingDone = await _localStorage.isOnboardingCompleted().timeout(
      const Duration(milliseconds: 500),
      onTimeout: () => false,
    );

    if (hasToken) {
      if (_featureFlags.forceShowStartup) {
        return AppRoutes.startupSkills;
      }
      final startupDone = await _localStorage.isStartupCompleted().timeout(
        const Duration(milliseconds: 500),
        onTimeout: () => false,
      );
      if (startupDone) {
        unawaited(AuthNavigation.bootstrapNotificationsIfNeeded());
      }
      return startupDone ? AppRoutes.home : AppRoutes.startupSkills;
    }

    if (!onboardingDone) {
      return AppRoutes.onboarding;
    }
    return AppRoutes.login;
  }
}
