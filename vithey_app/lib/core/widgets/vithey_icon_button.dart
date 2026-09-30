import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Visual variants for [VitheyIconButton].
enum VitheyIconButtonVariant {
  /// Heading-colored icon, no fill. Secondary / informational actions.
  neutral,

  /// Heading-colored icon, no fill. Default chrome.
  primary,

  /// Error-colored icon, no fill. Delete / block / report actions.
  destructive,
}

/// GenZ icon-first chrome: a ≥48×48 circular or squircle tap target with a
/// plain icon (no fill wash) and a 20–22px glyph.
///
/// Use for app bar actions, list-row leads, and inline actions instead of
/// one-off `Container` + `Icon` copies.
///
/// - [VitheyIconButtonVariant.primary]: heading-colored icon (default).
/// - [VitheyIconButtonVariant.neutral]: same plain look (kept for call sites).
/// - [VitheyIconButtonVariant.destructive]: error-colored icon, still no fill.
class VitheyIconButton extends StatelessWidget {
  const VitheyIconButton({
    super.key,
    required this.icon,
    this.onTap,
    this.variant = VitheyIconButtonVariant.primary,
    this.tooltip,
    this.size = VitheyRadii.iconButton,
    this.iconSize = 21,
    this.circle = false,
    this.enabled = true,
    this.color,
  }) : assert(size >= VitheyRadii.iconButton,
            'Icon button tap target must be >= ${VitheyRadii.iconButton}px');

  /// The icon to render (20–22 recommended).
  final IconData icon;

  /// Called on tap; when null the button renders disabled.
  final VoidCallback? onTap;

  /// Fill / foreground color scheme.
  final VitheyIconButtonVariant variant;

  /// Optional semantic tooltip / a11y label.
  final String? tooltip;

  /// Side of the tap target. Minimum [VitheyRadii.iconButton].
  final double size;

  /// Icon glyph size. 20–22 recommended.
  final double iconSize;

  /// When true the chrome is a full circle; otherwise a squircle with
  /// [VitheyRadii.iconSquircle] radius.
  final bool circle;

  final bool enabled;

  /// Overrides [variant] icon color when set (e.g. white on dark overlays).
  final Color? color;

  Color _iconColor(BuildContext context) {
    if (color != null) return color!;
    switch (variant) {
      case VitheyIconButtonVariant.primary:
        return context.appColors.heading;
      case VitheyIconButtonVariant.neutral:
        return context.appColors.heading;
      case VitheyIconButtonVariant.destructive:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = circle
        ? BorderRadius.circular(size / 2)
        : BorderRadius.circular(VitheyRadii.iconSquircle);
    final iconColor = _iconColor(context);

    Widget button = SizedBox(
      width: size,
      height: size,
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Center(
            child: VitheyIcon(
              icon,
              size: iconSize,
              color: enabled
                  ? iconColor
                  : iconColor.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      button = Tooltip(
        message: tooltip!,
        child: button,
      );
    }

    return button;
  }
}
