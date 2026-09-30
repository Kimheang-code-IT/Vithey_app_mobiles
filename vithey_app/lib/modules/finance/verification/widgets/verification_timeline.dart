import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class VerificationTimeline extends StatelessWidget {
  const VerificationTimeline({super.key, this.submittedAt});

  final DateTime? submittedAt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Status',
          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _TimelineStep(
          title: 'Application Submitted',
          subtitle: submittedAt != null ? _formatDate(submittedAt!) : 'Completed',
          tone: _StepTone.completed,
        ),
        const _TimelineStep(
          title: 'Under Review',
          subtitle: 'In progressing...',
          tone: _StepTone.active,
        ),
        const _TimelineStep(
          title: 'Verification Complete',
          subtitle: 'Pending',
          tone: _StepTone.idle,
          isLast: true,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}

enum _StepTone { completed, active, idle }

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.tone,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final _StepTone tone;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final Color iconColor;
    final Color badgeColor;
    final String badgeLabel;
    final IconData icon;
    switch (tone) {
      case _StepTone.completed:
        iconColor = AppColors.success;
        badgeColor = AppColors.success;
        badgeLabel = 'Completed';
        icon = LucideIcons.circleCheck;
      case _StepTone.active:
        iconColor = AppColors.pending;
        badgeColor = AppColors.pending;
        badgeLabel = 'In Review';
        icon = LucideIcons.clock;
      case _StepTone.idle:
        iconColor = context.appColors.muted;
        badgeColor = context.appColors.muted;
        badgeLabel = 'Pending';
        icon = LucideIcons.info;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: VitheyIcon(icon, color: iconColor, size: 24),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 18,
                margin: const EdgeInsets.symmetric(vertical: 2),
                color: context.appColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 4, top: 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700, color: context.appColors.heading),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(label: badgeLabel, color: badgeColor),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: context.text.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
