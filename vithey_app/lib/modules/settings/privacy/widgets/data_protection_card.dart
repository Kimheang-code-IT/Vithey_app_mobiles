import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/modules/settings/widgets/squircle_icon.dart';
import 'package:flutter/material.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class DataProtectionCard extends StatelessWidget {
  const DataProtectionCard({super.key, required this.onLearnMore});

  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return VitheyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SquircleIcon(icon: LucideIcons.shield, radius: 16),
              const SizedBox(width: 12),
              Text(
                'Data Protection',
                style: context.text.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Your data is encrypted and securely stored. We never share your personal information with third parties without your consent.',
            style: TextStyle(color: colors.heading, height: 1.4),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: VitheyTextLink(
              label: 'Learn more about our privacy practices →',
              fontSize: 13,
              onPressed: onLearnMore,
            ),
          ),
        ],
      ),
    );
  }
}
