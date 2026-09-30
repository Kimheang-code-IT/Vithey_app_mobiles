import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class WhatHappensNextList extends StatelessWidget {
  const WhatHappensNextList({super.key});

  static const _items = [
    (LucideIcons.eye, AppStrings.reviewStepReviewedTitle, AppStrings.reviewStepReviewedDesc),
    (LucideIcons.phone, AppStrings.reviewStepContactTitle, AppStrings.reviewStepContactDesc),
    (LucideIcons.bell, AppStrings.reviewStepDecisionTitle, AppStrings.reviewStepDecisionDesc),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.whatHappensNext,
            style: context.text.titleMedium,
          ),
          const SizedBox(height: 16),
          ..._items.map((item) => _InfoRow(icon: item.$1, title: item.$2, description: item.$3)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: VitheyIcon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.text.labelLarge),
                const SizedBox(height: 2),
                Text(description, style: context.text.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
