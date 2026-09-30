import 'dart:ui' show lerpDouble;

/// Continuous intro/auth wave ribbon (Language → … → Sign Up).
///
/// Source: `prompt/.../auth/Auth Background Wave Shape.md`
/// Y = absolute screen-height fraction (edge from top). Adjacent profiles share seams.
class WaveRibbonProfile {
  const WaveRibbonProfile({
    required this.id,
    required this.name,
    required this.tealX,
    required this.tealY,
    required this.lightX,
    required this.lightY,
  });

  final int id;
  final String name;
  final List<double> tealX;
  final List<double> tealY;
  final List<double> lightX;
  final List<double> lightY;

  /// Mean teal edge Y — useful for logo band height.
  double get meanTealY {
    if (tealY.isEmpty) return 0.4;
    return tealY.reduce((a, b) => a + b) / tealY.length;
  }

  WaveRibbonProfile lerp(WaveRibbonProfile other, double t) {
    final tt = t.clamp(0.0, 1.0);
    return WaveRibbonProfile(
      id: tt < 0.5 ? id : other.id,
      name: tt < 0.5 ? name : other.name,
      tealX: _lerpXs(tealX, other.tealX, tt),
      tealY: _lerpYs(tealX, tealY, other.tealX, other.tealY, tt),
      lightX: _lerpXs(lightX, other.lightX, tt),
      lightY: _lerpYs(lightX, lightY, other.lightX, other.lightY, tt),
    );
  }

  static List<double> _lerpXs(List<double> a, List<double> b, double t) {
    final n = a.length > b.length ? a.length : b.length;
    return [
      for (var i = 0; i < n; i++)
        lerpDouble(_at(a, i), _at(b, i), t)!,
    ];
  }

  static List<double> _lerpYs(
    List<double> ax,
    List<double> ay,
    List<double> bx,
    List<double> by,
    double t,
  ) {
    final xs = _lerpXs(ax, bx, t);
    return [
      for (final x in xs)
        lerpDouble(_sample(ax, ay, x), _sample(bx, by, x), t)!,
    ];
  }

  static double _at(List<double> xs, int i) {
    if (xs.isEmpty) return 0;
    if (i < xs.length) return xs[i];
    return xs.last;
  }

  /// Piecewise-linear sample of Y along X keyframes.
  static double _sample(List<double> xs, List<double> ys, double x) {
    if (xs.isEmpty) return 0.5;
    if (x <= xs.first) return ys.first;
    if (x >= xs.last) return ys.last;
    for (var i = 0; i < xs.length - 1; i++) {
      final x0 = xs[i];
      final x1 = xs[i + 1];
      if (x >= x0 && x <= x1) {
        final u = (x - x0) / (x1 - x0);
        return lerpDouble(ys[i], ys[i + 1], u)!;
      }
    }
    return ys.last;
  }
}

/// Ribbon index: 0 Language … 5 Sign Up.
abstract final class WaveRibbon {
  static const language = WaveRibbonProfile(
    id: 0,
    name: 'Language',
    tealX: [0.00, 0.18, 0.38, 0.62, 0.82, 1.00],
    tealY: [0.360, 0.390, 0.335, 0.415, 0.375, 0.400],
    lightX: [0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00],
    lightY: [0.410, 0.435, 0.380, 0.465, 0.420, 0.450, 0.460],
  );

  static const onboarding1 = WaveRibbonProfile(
    id: 1,
    name: 'Onboarding_1',
    tealX: [0.00, 0.18, 0.38, 0.62, 0.82, 1.00],
    tealY: [0.400, 0.385, 0.430, 0.415, 0.470, 0.500],
    lightX: [0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00],
    lightY: [0.460, 0.430, 0.480, 0.460, 0.520, 0.545, 0.560],
  );

  static const onboarding2 = WaveRibbonProfile(
    id: 2,
    name: 'Onboarding_2',
    tealX: [0.00, 0.18, 0.38, 0.62, 0.82, 1.00],
    tealY: [0.500, 0.480, 0.520, 0.485, 0.510, 0.500],
    lightX: [0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00],
    lightY: [0.560, 0.535, 0.575, 0.540, 0.560, 0.555, 0.538],
  );

  static const onboarding3 = WaveRibbonProfile(
    id: 3,
    name: 'Onboarding_3',
    tealX: [0.00, 0.25, 0.50, 0.75, 1.00],
    tealY: [0.500, 0.515, 0.428, 0.420, 0.400],
    lightX: [0.00, 0.20, 0.50, 0.72, 0.88, 1.00],
    lightY: [0.538, 0.570, 0.480, 0.475, 0.460, 0.455],
  );

  static const signIn = WaveRibbonProfile(
    id: 4,
    name: 'Sign In',
    tealX: [0.00, 0.18, 0.38, 0.62, 0.82, 1.00],
    tealY: [0.400, 0.340, 0.290, 0.325, 0.265, 0.240],
    lightX: [0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00],
    lightY: [0.455, 0.400, 0.350, 0.385, 0.320, 0.295, 0.300],
  );

  static const signUp = WaveRibbonProfile(
    id: 5,
    name: 'Sign Up',
    tealX: [0.00, 0.18, 0.38, 0.62, 0.82, 1.00],
    tealY: [0.240, 0.215, 0.255, 0.205, 0.230, 0.200],
    lightX: [0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00],
    lightY: [0.300, 0.265, 0.310, 0.250, 0.285, 0.255, 0.270],
  );

  /// Forgot password — teal band sits lower (~58%) to match Sign In wave style.
  static const forgotPassword = WaveRibbonProfile(
    id: 6,
    name: 'ForgotPassword',
    tealX: [0.00, 0.18, 0.38, 0.62, 0.82, 1.00],
    tealY: [0.580, 0.545, 0.610, 0.555, 0.595, 0.560],
    lightX: [0.00, 0.16, 0.36, 0.56, 0.76, 0.90, 1.00],
    lightY: [0.640, 0.600, 0.670, 0.610, 0.655, 0.620, 0.630],
  );

  static const List<WaveRibbonProfile> all = [
    language,
    onboarding1,
    onboarding2,
    onboarding3,
    signIn,
    signUp,
  ];

  static WaveRibbonProfile onboardingPage(int page) {
    switch (page.clamp(0, 2)) {
      case 0:
        return onboarding1;
      case 1:
        return onboarding2;
      default:
        return onboarding3;
    }
  }

  static WaveRibbonProfile authPage(int page) =>
      page == 0 ? signIn : signUp;
}
