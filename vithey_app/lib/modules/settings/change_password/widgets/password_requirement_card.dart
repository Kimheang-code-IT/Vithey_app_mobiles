import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class PasswordRequirementCard extends StatelessWidget {
  const PasswordRequirementCard({super.key, required this.requirements});

  /// Requirement label mapped to whether it is currently met.
  final Map<String, bool> requirements;

  @override
  Widget build(BuildContext context) {
    return VitheyCard(
      bordered: true,
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Requirements',
            style: context.text.labelLarge,
          ),
          const SizedBox(height: 12),
          for (final entry in requirements.entries)
            _RequirementRow(met: entry.value, text: entry.key),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.met, required this.text});

  final bool met;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final color = met ? context.scheme.primary : colors.muted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          VitheyIcon(
            met ? LucideIcons.circleCheck : LucideIcons.circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: context.text.labelLarge?.copyWith(
                color: color,
                fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
