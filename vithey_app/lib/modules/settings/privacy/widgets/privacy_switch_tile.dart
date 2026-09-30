import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';
import 'package:flutter/material.dart';

/// Privacy toggle row: squircle icon chrome, title + subtitle, and a
/// [VitheySwitch]. Lives inside a grouped [VitheyCard].
class PrivacySwitchTile extends StatelessWidget {
  const PrivacySwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.cardSurface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            SquircleIcon(icon: icon, radius: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.text.titleSmall),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: context.text.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
            VitheySwitch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
