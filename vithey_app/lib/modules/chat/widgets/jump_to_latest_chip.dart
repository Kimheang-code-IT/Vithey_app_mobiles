import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class JumpToLatestChip extends StatelessWidget {
  const JumpToLatestChip({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Material(
          elevation: 2,
          borderRadius: BorderRadius.circular(20),
          color: colors.cardSurface,
          shadowColor: colors.subtleShadow,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const VitheyIcon(
                    LucideIcons.chevronDown,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Jump to latest',
                    style: context.text.bodySmall
                        ?.copyWith(color: AppColors.primary),
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
