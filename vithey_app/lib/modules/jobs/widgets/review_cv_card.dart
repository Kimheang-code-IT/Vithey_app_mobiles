import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ReviewCvCard extends StatelessWidget {
  const ReviewCvCard({
    super.key,
    required this.fileName,
    required this.sizeLabel,
    required this.enabled,
    required this.onRemove,
    this.onTap,
  });

  final String fileName;
  final String sizeLabel;
  final bool enabled;
  final VoidCallback onRemove;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.appColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const VitheyIcon(LucideIcons.fileText, color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.labelLarge,
                      ),
                      if (sizeLabel.isNotEmpty)
                        Text(sizeLabel, style: context.text.bodySmall?.copyWith(fontSize: 12)),
                    ],
                  ),
                ),
                VitheyIconButton(
                  icon: LucideIcons.x,
                  variant: VitheyIconButtonVariant.destructive,
                  tooltip: 'Remove',
                  onTap: enabled ? onRemove : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
