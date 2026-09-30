import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class PositionSelector extends StatelessWidget {
  const PositionSelector({
    super.key,
    required this.position,
  });

  final String position;

  @override
  Widget build(BuildContext context) {
    if (position.trim().isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.position,
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Semantics(
            label: 'Position automatically selected from this job post',
            value: position,
            readOnly: true,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: context.appColors.inputFill,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.appColors.border),
              ),
              child: Row(
                children: [
                  VitheyIcon(
                    LucideIcons.briefcase,
                    size: 19,
                    color: context.appColors.muted,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      position,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelLarge,
                    ),
                  ),
                  const SizedBox(width: 8),
                  VitheyIcon(
                    LucideIcons.circleCheck,
                    size: 18,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Auto-selected from this job post',
            style: context.text.bodySmall?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
