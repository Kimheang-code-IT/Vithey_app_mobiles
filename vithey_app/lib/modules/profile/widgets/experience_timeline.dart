import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Experience (timeline + two-column) and Education lists for Application Detail v1.
class ExperienceTimeline extends StatelessWidget {
  const ExperienceTimeline({
    super.key,
    required this.title,
    required this.entries,
    this.useEducationIcon = false,
  });

  final String title;
  final List<dynamic> entries;
  final bool useEducationIcon;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: context.text.titleLarge),
        const SizedBox(height: 14),
        if (useEducationIcon)
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            if (entry is! ApplicantEducationEntry) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 14),
              child: _EducationRow(entry: entry, iconIndex: index),
            );
          })
        else
          ...List.generate(entries.length, (index) {
            final entry = entries[index];
            if (entry is! ApplicantExperienceEntry) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(bottom: index == entries.length - 1 ? 0 : 16),
              child: _ExperienceRow(entry: entry),
            );
          }),
      ],
    );
  }
}

class _ExperienceRow extends StatelessWidget {
  const _ExperienceRow({required this.entry});

  final ApplicantExperienceEntry entry;

  @override
  Widget build(BuildContext context) {
    // Dot + vertical line for every experience (title + description height).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.only(top: 4),
                    color: context.appColors.border,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: context.text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (entry.organization.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(entry.organization, style: context.text.bodySmall),
                      ],
                      if (entry.description != null && entry.description!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          entry.description!,
                          style: context.text.bodySmall?.copyWith(height: 1.4),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.period,
                    style: context.text.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
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

class _EducationRow extends StatelessWidget {
  const _EducationRow({required this.entry, required this.iconIndex});

  final ApplicantEducationEntry entry;
  final int iconIndex;

  @override
  Widget build(BuildContext context) {
    final icon = iconIndex == 0 ? LucideIcons.award : LucideIcons.graduationCap;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(VitheyRadii.iconSquircle),
          ),
          child: VitheyIcon(icon, color: AppColors.primary, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.school,
                      style: context.text.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.period,
                    style: context.text.labelMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                entry.degree,
                style: context.text.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
