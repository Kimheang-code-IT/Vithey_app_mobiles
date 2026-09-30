import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';

class ApplyJobContext extends StatelessWidget {
  const ApplyJobContext({
    super.key,
    required this.job,
    required this.eligibility,
    required this.isLoading,
    required this.onRetry,
    this.compact = false,
  });

  final FeedPost? job;
  final JobEligibilityResult? eligibility;
  final bool isLoading;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonLine(width: 180),
            SizedBox(height: 8),
            _SkeletonLine(width: 120),
          ],
        ),
      );
    }

    if (job == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Could not load job details',
              style: context.text.labelLarge,
            ),
            const SizedBox(height: 8),
            CustomButton(
              label: 'Retry',
              variant: CustomButtonVariant.outline,
              onPressed: onRetry,
            ),
          ],
        ),
      );
    }

    final title = job!.jobMeta.title ?? 'Job opportunity';
    final company = () {
      final raw = job!.jobMeta.description?.trim();
      if (raw == null || raw.isEmpty) return job!.author.fullName;
      final companyOnly = raw.split(' · ').first.trim();
      return companyOnly.isNotEmpty ? companyOnly : raw;
    }();
    final status = eligibility?.message;

    return Padding(
      padding: EdgeInsets.fromLTRB(compact ? 20 : 16, compact ? 0 : 8, compact ? 20 : 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Applying for $title',
            style: compact
                ? context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
                : context.text.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            company,
            style: compact
                ? context.text.bodySmall
                : context.text.bodyMedium?.copyWith(color: context.appColors.muted),
          ),
          if (!compact && job!.jobMeta.description != null && job!.jobMeta.description!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(job!.jobMeta.description!, style: const TextStyle(height: 1.4)),
          ],
          if (status != null && eligibility?.eligibility != JobEligibility.eligible) ...[
            const SizedBox(height: 12),
            Text(status, style: context.text.labelLarge?.copyWith(color: AppColors.warning)),
          ],
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 14,
      decoration: BoxDecoration(
        color: context.appColors.inputFill,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
