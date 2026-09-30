import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/jobs/models/application_detail_model.dart';
import 'package:intl/intl.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ApplicationStatusHero extends StatelessWidget {
  const ApplicationStatusHero({
    super.key,
    required this.detail,
    this.inCard = false,
  });

  final ApplicationDetailModel detail;
  final bool inCard;

  @override
  Widget build(BuildContext context) {
    if (detail.status == ApplicationStatus.accepted || detail.status == ApplicationStatus.rejected) {
      return _DecisionCard(detail: detail);
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: VitheyIcon(_iconFor(detail), size: 36, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          detail.heroTitle,
          textAlign: TextAlign.center,
          style: context.text.titleLarge,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            detail.heroSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: context.appColors.muted, height: 1.4),
          ),
        ),
      ],
    );
  }

  IconData _iconFor(ApplicationDetailModel detail) {
    if (detail.status == ApplicationStatus.reviewed ||
        (detail.status == ApplicationStatus.pending && detail.reviewStartedAt != null)) {
      return LucideIcons.users;
    }
    return LucideIcons.send;
  }
}

class _DecisionCard extends StatelessWidget {
  const _DecisionCard({required this.detail});

  final ApplicationDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final accepted = detail.status == ApplicationStatus.accepted;
    final headerColor = accepted ? AppColors.primary.withValues(alpha: 0.12) : context.appColors.dangerSurface;
    final titleColor = accepted ? AppColors.primary : AppColors.error;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.appColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: headerColor,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accepted ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: VitheyIcon(
                    accepted ? LucideIcons.circleCheck : LucideIcons.circleX,
                    color: titleColor,
                    size: accepted ? 28 : 32,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.heroTitle,
                        style: context.text.titleLarge?.copyWith(color: titleColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        detail.heroSubtitle,
                        style: context.text.bodySmall?.copyWith(color: context.appColors.heading, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ApplicationTimeline(steps: detail.buildTimeline()),
          ),
        ],
      ),
    );
  }
}

class ApplicationTimeline extends StatelessWidget {
  const ApplicationTimeline({super.key, required this.steps});

  final List<ApplicationTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;
        return _TimelineRow(step: step, isLast: isLast);
      }),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.isLast});

  final ApplicationTimelineStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM dd yyyy · h:mm a');

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _TimelineNode(step: step),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    decoration: BoxDecoration(
                      color: context.appColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.label, style: context.text.labelLarge),
                  const SizedBox(height: 4),
                  Text(
                    step.completedAt != null
                        ? dateFormat.format(step.completedAt!)
                        : (step.statusText ?? AppStrings.statusReviewBanner),
                    style: context.text.bodySmall?.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineNode extends StatelessWidget {
  const _TimelineNode({required this.step});

  final ApplicationTimelineStep step;

  @override
  Widget build(BuildContext context) {
    if (step.isRejectedDecision) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: const VitheyIcon(LucideIcons.flag, size: 13, color: AppColors.error),
      );
    }
    if (step.isAcceptedDecision) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const VitheyIcon(LucideIcons.flag, size: 13, color: Colors.white),
      );
    }
    if (step.isComplete) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppColors.primary,
          shape: BoxShape.circle,
        ),
        child: const VitheyIcon(LucideIcons.check, size: 14, color: Colors.white),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.appColors.cardSurface,
        border: Border.all(color: context.appColors.border, width: 2),
      ),
    );
  }
}

class StatusBannerCard extends StatelessWidget {
  const StatusBannerCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VitheyIcon(LucideIcons.bell, color: AppColors.primary, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: TextStyle(color: context.appColors.heading, height: 1.35)),
          ),
        ],
      ),
    );
  }
}

class StatusMessageCard extends StatelessWidget {
  const StatusMessageCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.appColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const VitheyIcon(LucideIcons.user, color: AppColors.primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '"$message"',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: context.appColors.heading,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
