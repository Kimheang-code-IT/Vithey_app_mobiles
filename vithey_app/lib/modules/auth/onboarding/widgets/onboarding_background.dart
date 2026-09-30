import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/auth/onboarding/widgets/wave_ribbon.dart';

/// Fixed intro/auth backdrop: white base + light-teal rear wave + teal front wave.
///
/// Edge shapes come from [WaveRibbonProfile] (absolute screen Y). Optional
/// [profileFrom] + [morphT] lerps between two ribbon cuts during a handoff.
class OnboardingBackground extends StatelessWidget {
  const OnboardingBackground({
    super.key,
    this.profile = WaveRibbon.onboarding1,
    this.profileFrom,
    this.morphT = 1.0,
    this.solidTeal = false,
  });

  /// Settled ribbon cut (Language … Sign Up).
  final WaveRibbonProfile profile;

  /// When set with [morphT] in (0,1), edges lerp from this → [profile].
  final WaveRibbonProfile? profileFrom;

  /// 0 = [profileFrom], 1 = [profile].
  final double morphT;

  /// Forgot-password / legacy full teal (no curves).
  final bool solidTeal;

  /// Approximate teal-band bottom for logo placement.
  static double tealBandHeightFraction(WaveRibbonProfile profile) {
    return profile.meanTealY.clamp(0.18, 0.72);
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = context.appColors.cardSurface;
    final waveRearColor = AppColors.waveRearOn(baseColor);
    final from = profileFrom;
    final t = morphT.clamp(0.0, 1.0);
    final edge = from == null || t >= 0.999
        ? profile
        : (t <= 0.001 ? from : from.lerp(profile, t));

    return SizedBox.expand(
      child: CustomPaint(
        painter: _OnboardingWavePainter(
          baseColor: baseColor,
          waveRearColor: waveRearColor,
          profile: edge,
          solidTeal: solidTeal,
        ),
      ),
    );
  }
}

class _OnboardingWavePainter extends CustomPainter {
  const _OnboardingWavePainter({
    required this.baseColor,
    required this.waveRearColor,
    required this.profile,
    required this.solidTeal,
  });

  final Color baseColor;
  final Color waveRearColor;
  final WaveRibbonProfile profile;
  final bool solidTeal;

  @override
  void paint(Canvas canvas, Size size) {
    if (solidTeal) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = AppColors.primaryLight,
      );
      return;
    }

    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    canvas.drawPath(
      _layerPath(size, profile.lightX, profile.lightY),
      Paint()..color = waveRearColor,
    );
    canvas.drawPath(
      _layerPath(size, profile.tealX, profile.tealY),
      Paint()..color = AppColors.primaryLight,
    );
  }

  Path _layerPath(Size size, List<double> xFrac, List<double> yFrac) {
    assert(xFrac.length == yFrac.length);
    final pts = <Offset>[
      for (var i = 0; i < xFrac.length; i++)
        Offset(size.width * xFrac[i], size.height * yFrac[i]),
    ];

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(pts.last.dx, pts.last.dy);

    final edge = pts.reversed.toList();
    for (var i = 0; i < edge.length - 1; i++) {
      final p0 = i > 0 ? edge[i - 1] : edge[i];
      final p1 = edge[i];
      final p2 = edge[i + 1];
      final p3 = i + 2 < edge.length ? edge[i + 2] : edge[i + 1];

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _OnboardingWavePainter oldDelegate) {
    return baseColor != oldDelegate.baseColor ||
        waveRearColor != oldDelegate.waveRearColor ||
        solidTeal != oldDelegate.solidTeal ||
        profile.id != oldDelegate.profile.id ||
        profile.tealY != oldDelegate.profile.tealY ||
        profile.lightY != oldDelegate.profile.lightY;
  }
}
