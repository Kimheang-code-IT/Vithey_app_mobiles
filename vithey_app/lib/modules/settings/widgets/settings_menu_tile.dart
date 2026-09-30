import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Settings-home menu row — TikTok-style: plain icon, label, chevron.
class SettingsMenuTile extends StatelessWidget {
  const SettingsMenuTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.onTap,
    this.showChevron = true,
  });

  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: context.scheme.primary),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: context.text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: context.text.bodySmall?.copyWith(height: 1.25),
                      ),
                    ],
                  ],
                ),
              ),
              if (showChevron)
                Icon(
                  LucideIcons.chevronRight,
                  size: 22,
                  color: colors.muted.withValues(alpha: 0.7),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
