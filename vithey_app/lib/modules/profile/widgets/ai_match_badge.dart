import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Compact AI match badge for the poster applicants list (AI-JOB-09).
/// Score colors follow the same bands as the match result label.
class AiMatchBadge extends StatelessWidget {
  const AiMatchBadge({super.key, required this.score});

  final int score;

  Color get _color => switch (score) {
        >= 80 => AppColors.success,
        >= 65 => AppColors.primary,
        >= 45 => AppColors.warning,
        _ => AppColors.error,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
        border: Border.all(color: _color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VitheyIcon(LucideIcons.sparkles, size: 11, color: _color),
          const SizedBox(width: 4),
          Text(
            '$score% match',
            style: context.text.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: _color,
            ),
          ),
        ],
      ),
    );
  }
}
