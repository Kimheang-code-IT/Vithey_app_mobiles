import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lucide icon rendered with a bold stroke.
///
/// The `LucideIcons` font bundled with `shadcn_flutter` is a static,
/// single-weight font (no variable `wght` axis), so glyph strokes cannot be
/// thickened through font settings. [VitheyIcon] draws the same glyph but
/// dilates it with crisp, zero-blur shadows in 8 directions, thickening the
/// stroke by roughly `2 * [strokeBoost] * size` pixels — visually equivalent
/// to Lucide's `stroke-width: 2.5–3` (bold).
///
/// Drop-in replacement for `Icon` — same constructor shape (`icon`, `size`,
/// `color`, `semanticLabel`, `shadows`), same `IconTheme` fallbacks.
class VitheyIcon extends StatelessWidget {
  /// How much of the icon size to dilate the glyph on each side.
  ///
  /// `0.018` at a 24px icon ≈ +0.86px stroke. Tune globally if needed.
  static double strokeBoost = 0.018;

  /// Minimum dilation in logical pixels (keeps small icons readable).
  static double minBoost = 0.35;

  const VitheyIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.semanticLabel,
    this.shadows,
  });

  final IconData icon;

  /// Icon size. Defaults to `IconTheme.size` (24.0).
  final double? size;

  /// Icon color. Defaults to `IconTheme.color`.
  final Color? color;

  /// Semantic description for accessibility.
  final String? semanticLabel;

  /// Extra shadows (e.g. drop shadows) layered under the dilation shadows.
  final List<Shadow>? shadows;

  /// 8-direction zero-blur dilation — the union of the glyph plus its offset
  /// copies thickens the stroke without blurring edges.
  static List<Shadow> dilationShadows(Color color, double d) {
    const k = 0.70710678; // diagonal scale so 8 directions ≈ circular dilation
    return <Shadow>[
      Shadow(color: color, offset: Offset(d, 0)),
      Shadow(color: color, offset: Offset(-d, 0)),
      Shadow(color: color, offset: Offset(0, d)),
      Shadow(color: color, offset: Offset(0, -d)),
      Shadow(color: color, offset: Offset(d * k, d * k)),
      Shadow(color: color, offset: Offset(-d * k, d * k)),
      Shadow(color: color, offset: Offset(d * k, -d * k)),
      Shadow(color: color, offset: Offset(-d * k, -d * k)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final effectiveSize = size ?? theme.size ?? 24.0;
    Color effectiveColor =
        color ?? theme.color ?? Theme.of(context).colorScheme.onSurface;

    final double opacity = theme.opacity ?? 1.0;
    if (opacity < 1.0) {
      effectiveColor =
          effectiveColor.withValues(alpha: effectiveColor.a * opacity);
    }

    final double d = math.max(minBoost, effectiveSize * strokeBoost);

    final richText = Text.rich(
      TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          inherit: false,
          color: effectiveColor,
          fontSize: effectiveSize,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          height: 1.0,
          leadingDistribution: TextLeadingDistribution.even,
          shadows: [
            ...?shadows,
            ...dilationShadows(effectiveColor, d),
          ],
        ),
      ),
      textAlign: TextAlign.center,
      overflow: TextOverflow.visible,
    );

    // Match Flutter [Icon]: fixed square box + centered glyph so parents
    // (nav circles, buttons) never see top-left bias from RichText.
    final boxed = SizedBox(
      width: effectiveSize,
      height: effectiveSize,
      child: Center(child: richText),
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: boxed);
    }
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: boxed,
    );
  }
}
