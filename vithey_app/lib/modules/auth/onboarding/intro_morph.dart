import 'package:flutter/animation.dart';

/// Intro handoff flags. Morph animations run on the **entering** screen only.
///
/// Ribbon continuum: Language(0) → Onb1(1) → Onb2(2) → Onb3(3) → SignIn(4) → SignUp(5).
/// Forward (index↑) slides **left**; backward (index↓) slides **right**.
class IntroMorph {
  IntroMorph._();

  /// Language ↔ Onboarding content fade on enter.
  static const duration = Duration(milliseconds: 360);

  /// Whole-frame ribbon slide (Onboarding pages, Sign In ↔ Sign Up).
  static const panelDuration = Duration(milliseconds: 560);

  /// Onboarding ↔ Auth: content fade in/out.
  static const authContentDuration = Duration(milliseconds: 180);

  static bool fadeContentIn = false;
  static bool fromLanguage = false;
  static bool fromOnboarding = false;
  static bool fromAuth = false;
  static int initialOnboardingPage = 0;

  /// When entering Auth, start on Sign Up (register route).
  static bool startOnSignUp = false;

  static void clear() {
    fadeContentIn = false;
    fromLanguage = false;
    fromOnboarding = false;
    fromAuth = false;
    initialOnboardingPage = 0;
    startOnSignUp = false;
  }

  static Future<void> run(
    Duration duration,
    void Function(double t) onTick,
  ) async {
    const steps = 22;
    final stepMs =
        (duration.inMilliseconds / steps).clamp(8, 36).round();
    for (var i = 1; i <= steps; i++) {
      await Future<void>.delayed(Duration(milliseconds: stepMs));
      onTick(Curves.easeInOutCubic.transform(i / steps));
    }
    onTick(1);
  }
}
