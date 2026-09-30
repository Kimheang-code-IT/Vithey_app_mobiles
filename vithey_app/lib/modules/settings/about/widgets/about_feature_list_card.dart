import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/settings/about/widgets/about_info_card.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class AboutFeatureListCard extends StatelessWidget {
  const AboutFeatureListCard({super.key, required this.features});

  final List<String> features;

  @override
  Widget build(BuildContext context) {
    return AboutSectionCard(
      title: 'Core Features',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  VitheyIcon(LucideIcons.circle, size: 8, color: context.scheme.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: TextStyle(color: context.appColors.heading),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
