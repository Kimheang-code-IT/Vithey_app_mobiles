import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Splash-only backdrop.
/// Sheet base → white-50% drops first → teal drops on top.
///
/// Teal fill is always [AppColors.primaryLight] (same as onboarding / auth), light and dark.
/// Base + wash follow sheet tokens so the lead layer stays theme-aware.
class SplashBackground extends StatelessWidget {
  const SplashBackground({
    super.key,
    this.washFill = 0.0,
    this.tealFill = 0.0,
  });

  /// White-50% drop progress (starts first).
  final double washFill;

  /// Teal drop progress (overlaps wash; must reach 1 for full cover).
  final double tealFill;

  @override
  Widget build(BuildContext context) {
    final baseColor = context.appColors.cardSurface;
    // Same brand teal as onboarding / auth / select language — both themes.
    const tealColor = AppColors.primaryLight;
    // White-50% lead = teal @ 50% on the sheet base (light or dark).
    final washColor = AppColors.waveRearOn(baseColor);

    return CustomPaint(
      painter: _SplashFillPainter(
        washFill: washFill.clamp(0.0, 1.0),
        tealFill: tealFill.clamp(0.0, 1.0),
        baseColor: baseColor,
        washColor: washColor,
        tealColor: tealColor,
      ),
      size: Size.infinite,
    );
  }
}

class _SplashFillPainter extends CustomPainter {
  const _SplashFillPainter({
    required this.washFill,
    required this.tealFill,
    required this.baseColor,
    required this.washColor,
    required this.tealColor,
  });

  final double washFill;
  final double tealFill;
  final Color baseColor;
  final Color washColor;
  final Color tealColor;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Sheet base first (white in light, darkSurface in dark).
    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    // 2) White-50% / light rear drops first.
    if (washFill > 0.001 && tealFill < 1.0) {
      _paintDropLayer(
        canvas,
        size,
        progress: washFill,
        color: washColor,
        phase: 0.35,
      );
    }

    // 3) Brand teal on top — solid full screen once complete.
    if (tealFill >= 0.999) {
      canvas.drawRect(Offset.zero & size, Paint()..color = tealColor);
      return;
    }

    if (tealFill > 0.001) {
      _paintDropLayer(
        canvas,
        size,
        progress: tealFill,
        color: tealColor,
        phase: 0.0,
      );
    }
  }

  void _paintDropLayer(
    Canvas canvas,
    Size size, {
    required double progress,
    required Color color,
    required double phase,
  }) {
    final w = size.width;
    final h = size.height;
    canvas.save();
    if (progress >= 0.999) {
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    } else {
      canvas.clipPath(_revealClip(w, h, progress, phase: phase));
      canvas.drawRect(Offset.zero & size, Paint()..color = color);
    }
    canvas.restore();
  }

  /// Soft wave leading edge (Vithey-style curve — smooth, not sharp).
  /// Wave only extends downward — never leaves a gap.
  Path _revealClip(
    double w,
    double h,
    double progress, {
    required double phase,
  }) {
    final baseY = math.min(h, h * progress + h * 0.04);

    final amp = h * 0.045;
    Offset point(double t) {
      final x = w * (1.0 - t);
      final wave = math.sin(t * math.pi + phase) * amp +
          math.sin(t * math.pi * 0.5 + phase * 0.6) * amp * 0.35;
      final y = math.min(h, baseY + math.max(0.0, wave + amp * 0.35));
      return Offset(x, y);
    }

    final pts = <Offset>[
      for (var i = 0; i <= 6; i++) point(i / 6),
    ];

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(pts.first.dx, pts.first.dy);

    for (var i = 0; i < pts.length - 1; i++) {
      final p0 = i > 0 ? pts[i - 1] : pts[i];
      final p1 = pts[i];
      final p2 = pts[i + 1];
      final p3 = i + 2 < pts.length ? pts[i + 2] : pts[i + 1];
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
  bool shouldRepaint(covariant _SplashFillPainter oldDelegate) {
    return oldDelegate.washFill != washFill ||
        oldDelegate.tealFill != tealFill ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.washColor != washColor ||
        oldDelegate.tealColor != tealColor;
  }
}
