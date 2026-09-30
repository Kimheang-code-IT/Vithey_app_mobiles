import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_switch.dart';
import 'package:aub_connect_app/modules/settings/notification_preferences/widgets/notification_preference_card.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class NotificationMasterCard extends StatelessWidget {
  const NotificationMasterCard({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final primary = context.scheme.primary;

    return NotificationPreferenceCard(
      children: [
        Semantics(
          toggled: value,
          label: 'Allow Notifications. Receive alerts from Vithey',
          child: Material(
            color: context.appColors.cardSurface,
            child: InkWell(
              onTap: () => onChanged(!value),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Row(
                  children: [
                    Icon(
                      LucideIcons.bell,
                      color: primary,
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allow Notifications',
                            style: context.text.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Receive alerts from Vithey',
                            style: context.text.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    VitheySwitch(value: value, onChanged: onChanged),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
