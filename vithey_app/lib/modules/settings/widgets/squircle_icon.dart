import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Soft squircle chrome for settings-row leading icons (16–18 radius).
///
/// Tinted wash background that reads on light and dark, per the GenZ
/// shape language ("leading icons sit in soft squircles, never raw
/// circles or bare glyphs").
class SquircleIcon extends StatelessWidget {
  const SquircleIcon({
    super.key,
    required this.icon,
    this.size = 40,
    this.radius = VitheyRadii.iconSquircle,
    this.color,
    this.opacity = 1,
  });

  final IconData icon;

  /// Side of the squircle container.
  final double size;

  /// Corner radius — 16–18 per DESIGN_SYSTEM.md.
  final double radius;

  /// Accent color; defaults to the theme primary.
  final Color? color;

  /// Overall opacity — used to dim "Coming soon" rows.
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? context.scheme.primary;
    final alpha = context.isDarkMode ? 0.20 : 0.12;

    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: VitheyIcon(icon, size: size * 0.5, color: accent),
      ),
    );
  }
}
