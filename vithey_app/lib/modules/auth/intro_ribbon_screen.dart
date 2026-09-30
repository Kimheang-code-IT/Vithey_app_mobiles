import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_logo.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/modules/auth/auth_controller.dart';
import 'package:aub_connect_app/modules/auth/intro_ribbon_controller.dart';
import 'package:aub_connect_app/modules/auth/language/select_language_controller.dart';
import 'package:aub_connect_app/modules/auth/login_screen.dart';
import 'package:aub_connect_app/modules/auth/onboarding/onboarding_controller.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_background.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_bottom_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/onboarding_top_section.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Language → Onboarding×3 → Sign In → Sign Up as one PageView continuum.
/// Forward slides left; back slides right — **buttons only** (no finger swipe).
///
/// Dots + Continue/Next/Get Started stay **fixed** on Language → Onboarding 1–3.
/// They only **slide left** when leaving the last onboarding page into Auth.
/// Back/Skip stay fixed. Auth logo slides in with Sign In, then Y-tracks on Sign In ↔ Sign Up.
class IntroRibbonScreen extends StatefulWidget {
  const IntroRibbonScreen({super.key});

  @override
  State<IntroRibbonScreen> createState() => _IntroRibbonScreenState();
}

class _IntroRibbonScreenState extends State<IntroRibbonScreen>
    with SingleTickerProviderStateMixin {
  static const _forgotMorphDuration = Duration(milliseconds: 560);

  IntroRibbonController get controller => Get.find<IntroRibbonController>();

  late final AnimationController _forgotMorph;
  Worker? _forgotWorker;
  var _enteringAuth = false;

  @override
  void initState() {
    super.initState();
    _forgotMorph = AnimationController(
      vsync: this,
      duration: _forgotMorphDuration,
    );
    controller.pageController.addListener(_onPageScroll);
    if (Get.isRegistered<AuthController>()) {
      final auth = Get.find<AuthController>();
      if (auth.showForgotPassword.value) {
        _forgotMorph.value = 1;
      }
      _forgotWorker = ever<bool>(auth.showForgotPassword, (show) {
        if (!mounted) return;
        if (show) {
          FocusManager.instance.primaryFocus?.unfocus();
          _forgotMorph.forward();
        } else {
          FocusManager.instance.primaryFocus?.unfocus();
          _forgotMorph.reverse();
        }
      });
    }
  }

  @override
  void dispose() {
    _forgotWorker?.dispose();
    controller.pageController.removeListener(_onPageScroll);
    _forgotMorph.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    if (mounted) setState(() {});
  }

  double get _page {
    final pc = controller.pageController;
    if (pc.hasClients && pc.page != null) return pc.page!;
    return controller.currentPage.value.toDouble();
  }

  /// Chrome visible through last onboarding; gone once Sign In is settled.
  double get _introChromeOpacity {
    final page = _page;
    if (page >= IntroRibbonController.pageSignIn) return 0;
    return 1;
  }

  /// Horizontal slide only after last onboarding (into Auth).
  double _introChromeDx(double page, double screenW) {
    if (page <= IntroRibbonController.pageOnboarding3) return 0;
    return (IntroRibbonController.pageOnboarding3 - page) * screenW;
  }

  /// Skip visible on onboarding pages only.
  double get _skipOpacity {
    final page = _page;
    if (page < IntroRibbonController.pageOnboarding1) return 0;
    if (page >= IntroRibbonController.pageSignIn) return 0;
    if (page <= IntroRibbonController.pageOnboarding3) return 1;
    return (IntroRibbonController.pageSignIn - page).clamp(0.0, 1.0);
  }

  /// Logo band height — tracks teal center on Sign In ↔ Sign Up / Forgot.
  WaveRibbonProfile _logoTrackProfile(double page, double forgotT) {
    final signUpT = (page - IntroRibbonController.pageSignIn).clamp(0.0, 1.0);
    final waveForgotT = Curves.easeInOutCubic.transform(
      const Interval(0.12, 0.88).transform(forgotT),
    );
    final fromSignIn =
        WaveRibbon.signIn.lerp(WaveRibbon.forgotPassword, waveForgotT);
    return fromSignIn.lerp(WaveRibbon.signUp, signUpT);
  }

  void _onFixedBack() {
    final page = _page;
    final auth = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : null;
    if (auth != null &&
        auth.showForgotPassword.value &&
        page < IntroRibbonController.pageSignUp) {
      auth.closeForgotPassword();
      return;
    }
    if (page >= IntroRibbonController.pageSignIn) {
      if (page >= IntroRibbonController.pageSignUp - 0.01) {
        controller.showSignIn();
      } else {
        controller.authBack();
      }
      return;
    }
    controller.onboardingBack();
  }

  Future<void> _enterAuth() async {
    if (_enteringAuth || controller.isBusy.value) return;
    _enteringAuth = true;
    try {
      await controller.finishOnboarding();
    } finally {
      if (mounted) _enteringAuth = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.sizeOf(context).height;
    final screenW = MediaQuery.sizeOf(context).width;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: context.appColors.cardSurface,
      body: AnimatedBuilder(
        animation: _forgotMorph,
        builder: (context, _) {
          return Obx(() {
            final busy = controller.isBusy.value || _enteringAuth;
            final settled = controller.currentPage.value;
            final page = _page;
            final chromeOpacity = _introChromeOpacity;
            final chromeDx = _introChromeDx(page, screenW);
            final skipOpacity = _skipOpacity;
            final showSkip = page >= IntroRibbonController.pageOnboarding1 &&
                page < IntroRibbonController.pageSignIn;
            final showFixedBack = page >= IntroRibbonController.pageOnboarding1;
            final onLastOnboarding =
                settled == IntroRibbonController.pageOnboarding3;
            final logoProfile =
                _logoTrackProfile(page, _forgotMorph.value);
            final tealBandH = screenH *
                OnboardingBackground.tealBandHeightFraction(logoProfile);
            final showAuthLogo = page > IntroRibbonController.pageOnboarding3;
            final logoDx = page < IntroRibbonController.pageSignIn
                ? (IntroRibbonController.pageSignIn - page) * screenW
                : 0.0;

            return IgnorePointer(
              ignoring: busy,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    controller: controller.pageController,
                    onPageChanged: controller.onPageChanged,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: IntroRibbonController.pageCount,
                    itemBuilder: (context, index) {
                      switch (index) {
                        case IntroRibbonController.pageLanguage:
                          return const _LanguagePage();
                        case IntroRibbonController.pageOnboarding1:
                          return _OnboardingPage(
                            controller: controller,
                            slideIndex: 0,
                          );
                        case IntroRibbonController.pageOnboarding2:
                          return _OnboardingPage(
                            controller: controller,
                            slideIndex: 1,
                          );
                        case IntroRibbonController.pageOnboarding3:
                          return _OnboardingPage(
                            controller: controller,
                            slideIndex: 2,
                          );
                        case IntroRibbonController.pageSignIn:
                          return AuthRibbonFrame(
                            profile: WaveRibbon.signIn,
                            form: const AuthSignInForm(),
                            onBack: controller.authBack,
                            enableForgotMorph: true,
                            omitFixedChrome: true,
                            forgotMorphListenable: _forgotMorph,
                          );
                        case IntroRibbonController.pageSignUp:
                        default:
                          return AuthRibbonFrame(
                            profile: WaveRibbon.signUp,
                            form: const AuthSignUpForm(),
                            onBack: controller.authBack,
                            omitFixedChrome: true,
                          );
                      }
                    },
                  ),
                  if (showAuthLogo)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: tealBandH,
                      child: IgnorePointer(
                        child: Transform.translate(
                          offset: Offset(logoDx, 0),
                          child: const Center(
                            child: AppLogo(
                              size: 100,
                              onWhiteCircle: true,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showSkip && skipOpacity > 0.01)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IgnorePointer(
                        ignoring: skipOpacity < 0.5,
                        child: Opacity(
                          opacity: skipOpacity,
                          child: SafeArea(
                            child: CustomButton(
                              label: 'Skip',
                              variant: CustomButtonVariant.ghost,
                              foregroundColor: AppColors.accentLight,
                              onPressed: _enterAuth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showFixedBack)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: SafeArea(
                        child: CustomButton(
                          label: AppStrings.back,
                          variant: CustomButtonVariant.ghost,
                          foregroundColor: AppColors.accentLight,
                          onPressed: _onFixedBack,
                        ),
                      ),
                    ),
                  if (chromeOpacity > 0.01)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        ignoring: chromeOpacity < 0.5 ||
                            page > IntroRibbonController.pageOnboarding3,
                        child: Opacity(
                          opacity: chromeOpacity,
                          child: Transform.translate(
                            offset: Offset(chromeDx, 0),
                            child: OnboardingBottomChrome(
                              currentPage: settled.clamp(
                                0,
                                OnboardingController.introDotCount - 1,
                              ),
                              totalPages: OnboardingController.introDotCount,
                              onNext: settled ==
                                      IntroRibbonController.pageLanguage
                                  ? controller.languageContinue
                                  : onLastOnboarding
                                      ? _enterAuth
                                      : controller.onboardingNext,
                              isLastSlide: onLastOnboarding,
                              nextLabel: settled ==
                                      IntroRibbonController.pageLanguage
                                  ? 'Continue'
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          });
        },
      ),
    );
  }
}

class _LanguagePage extends StatelessWidget {
  const _LanguagePage();

  Color _secondary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFB0B0BE) : const Color(0xFF5A5A68);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IntroRibbonController>();
    final heading = context.appColors.heading;
    final secondary = _secondary(context);
    final border = context.appColors.border;

    return Stack(
      fit: StackFit.expand,
      children: [
        const OnboardingBackground(profile: WaveRibbon.language),
        Column(
          children: [
            const Expanded(
              flex: 34,
              child: SafeArea(
                bottom: false,
                child: Center(
                  child: AppLogo(size: 100, onWhiteCircle: true),
                ),
              ),
            ),
            Expanded(
              flex: 66,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 112),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
                    child: Column(
                      children: [
                        const Spacer(flex: 5),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Select Language',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: heading,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Choose your preferred language for the app.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.4,
                                  color: secondary,
                                ),
                              ),
                              const SizedBox(height: 40),
                              Obx(() {
                                final selected =
                                    controller.selectedLanguage.value;
                                return DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: border),
                                  ),
                                  child: Column(
                                    children: [
                                      _LanguageRow(
                                        flagAsset: AppAssets.englishLanguage,
                                        title: 'English (US)',
                                        subtitle: 'English',
                                        selected:
                                            selected == AppLanguageOption.en,
                                        secondary: secondary,
                                        onTap: () => controller.selectLanguage(
                                          AppLanguageOption.en,
                                        ),
                                      ),
                                      Divider(height: 1, color: border),
                                      _LanguageRow(
                                        flagAsset: AppAssets.khmerLanguage,
                                        title: 'Khmer',
                                        subtitle: 'ភាសាខ្មែរ',
                                        selected:
                                            selected == AppLanguageOption.km,
                                        secondary: secondary,
                                        onTap: () => controller.selectLanguage(
                                          AppLanguageOption.km,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.flagAsset,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.secondary,
    required this.onTap,
  });

  final String flagAsset;
  final String title;
  final String subtitle;
  final bool selected;
  final Color secondary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            ClipOval(
              child: Image.asset(
                flagAsset,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: context.appColors.heading,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: secondary),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: AppColors.primary, size: 24)
            else
              const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    required this.controller,
    required this.slideIndex,
  });

  final IntroRibbonController controller;
  final int slideIndex;

  @override
  Widget build(BuildContext context) {
    final slide = controller.onboardingSlides[slideIndex];
    final profile = WaveRibbon.onboardingPage(slideIndex);

    return Stack(
      fit: StackFit.expand,
      children: [
        OnboardingBackground(profile: profile),
        Column(
          children: [
            Expanded(
              flex: 55,
              child: OnboardingTopSection(imageAsset: slide.imageAsset),
            ),
            Expanded(
              flex: 45,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 112),
                child: OnboardingBottomSection(
                  title: slide.title,
                  description: slide.description,
                  currentPage: slideIndex,
                  totalPages: controller.onboardingSlides.length,
                  onNext: controller.onboardingNext,
                  showChrome: false,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
