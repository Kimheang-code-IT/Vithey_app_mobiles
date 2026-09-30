import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// GenZ card shell for search result tiles.
///
/// Radius-16 surface with a soft border, 12px outer margin, and rounded
/// ripple. All search result tiles (people / posts / jobs / videos) build
/// on this so the results list reads as a stack of soft cards.
class SearchResultTileCard extends StatelessWidget {
  const SearchResultTileCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: margin,
      child: Material(
        color: colors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Round tinted trailing icon button used on result tiles (e.g. the
/// message action on people results).
class SearchResultRoundAction extends StatelessWidget {
  const SearchResultRoundAction({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 40,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = Material(
      color: context.scheme.primary.withValues(alpha: 0.12),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: VitheyIcon(icon, size: 20, color: context.scheme.primary),
        ),
      ),
    );

    if (tooltip == null) return button;
    return Tooltip(message: tooltip!, child: button);
  }
}
