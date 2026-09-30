import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/vithey_type.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// App-wide surface card built on [shad.Card].
///
/// Use for settings groups, info panels, and form field shells.
/// Feed/post cards can stay specialized.
class VitheyCard extends StatelessWidget {
  const VitheyCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.bordered = false,
    this.elevated = true,
    this.clipBehavior = Clip.antiAlias,
    this.borderRadius = VitheyRadii.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final bool bordered;
  final bool elevated;
  final Clip clipBehavior;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(borderRadius);

    final card = shad.Card(
      filled: true,
      fillColor: colors.cardSurface,
      borderRadius: radius,
      borderColor: bordered ? colors.border : Colors.transparent,
      borderWidth: bordered ? 1 : 0,
      boxShadow: elevated
          ? [
              BoxShadow(
                color: colors.subtleShadow,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
          : const [],
      padding: padding,
      clipBehavior: clipBehavior,
      child: onTap == null
          ? child
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: radius,
                child: child,
              ),
            ),
    );

    if (margin == null) return card;
    return Padding(padding: margin!, child: card);
  }
}

/// Labeled icon header + body, used for account / settings info rows.
class VitheyInfoCard extends StatelessWidget {
  const VitheyInfoCard({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
    this.onTap,
    this.trailing,
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  final IconData icon;
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;

    return VitheyCard(
      margin: margin,
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              VitheyIcon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: context.text.bodySmall
                      ?.copyWith(fontWeight: VitheyWeight.medium),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
