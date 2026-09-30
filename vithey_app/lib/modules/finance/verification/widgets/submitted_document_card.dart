import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SubmittedDocumentCard extends StatelessWidget {
  const SubmittedDocumentCard({super.key, this.fileName});

  /// Uploaded file from the verification form. When null/empty, only the
  /// Student ID Card status row is shown.
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    final uploadedName = fileName?.trim();
    final hasUploadedFile =
        uploadedName != null && uploadedName.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Submitted Documents',
            style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: context.appColors.heading),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              VitheyIcon(
                LucideIcons.badge,
                color: context.appColors.muted,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Student ID Card',
                  style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: context.appColors.heading),
                ),
              ),
              const StatusBadge(label: 'Uploaded', color: AppColors.success),
            ],
          ),
          if (hasUploadedFile) ...[
            const SizedBox(height: 12),
            Divider(height: 1, color: context.appColors.border),
            const SizedBox(height: 12),
            Row(
              children: [
                VitheyIcon(
                  _iconForName(uploadedName),
                  color: AppColors.primary,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    uploadedName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: context.appColors.heading),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  IconData _iconForName(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.pdf')) return LucideIcons.fileText;
    if (lower.endsWith('.doc') || lower.endsWith('.docx')) {
      return LucideIcons.fileText;
    }
    if (lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp')) {
      return LucideIcons.image;
    }
    return LucideIcons.fileText;
  }
}
