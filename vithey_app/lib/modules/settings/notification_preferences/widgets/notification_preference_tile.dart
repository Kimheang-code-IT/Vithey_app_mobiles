import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';

class NotificationPreferenceTile extends StatelessWidget {
  const NotificationPreferenceTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      enabled: enabled,
      label: '$title. $subtitle',
      child: Material(
        color: context.appColors.cardSurface,
        child: InkWell(
          onTap: enabled ? () => onChanged(!value) : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: enabled ? 1 : 0.48,
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
                        Text(
                          title,
                          style: context.text.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: context.text.bodySmall?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  VitheySwitch(
                    value: value,
                    enabled: enabled,
                    onChanged: onChanged,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
