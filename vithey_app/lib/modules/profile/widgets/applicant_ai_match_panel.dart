import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/ai_job_match_result.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Applicant detail — AI match certify panel (AI-JOB-08, AI-JOB-13).
///
/// Poster-side view of one applicant's job match: score + label, matched
/// skills, gaps, reasons and the always-visible disclaimer. Loads the mock
/// match via `AiRepository.matchJob`. Gating with
/// `FeatureFlags.useAiJobMatch` is done by the caller.
class ApplicantAiMatchPanel extends StatefulWidget {
  const ApplicantAiMatchPanel({
    super.key,
    required this.jobPostId,
    required this.applicantUserId,
    required this.applicantName,
  });

  final String jobPostId;
  final String? applicantUserId;
  final String applicantName;

  @override
  State<ApplicantAiMatchPanel> createState() => _ApplicantAiMatchPanelState();
}

class _ApplicantAiMatchPanelState extends State<ApplicantAiMatchPanel> {
  AiJobMatchResult? _match;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await Get.find<AiRepository>().matchJob(
        jobPostId: widget.jobPostId,
        applicantUserId: widget.applicantUserId,
      );
      if (!mounted) return;
      setState(() => _match = result);
    } catch (_) {
      // Panel hides silently — AI assist must never block poster decisions.
      if (!mounted) return;
      setState(() => _match = null);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _askHowToImprove() {
    final prompt =
        'How could ${widget.applicantName} improve their match for this job?';
    Get.toNamed(AppRoutes.chatbot, arguments: prompt);
  }

  @override
  Widget build(BuildContext context) {
    final title = Row(
      children: [
        VitheyIcon(LucideIcons.sparkles,
            size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'AI Match Score',
            style: context.text.titleLarge,
          ),
        ),
      ],
    );

    if (_loading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 10),
              Text(
                'Vithey AI is checking the match…',
                style: context.text.bodySmall,
              ),
            ],
          ),
        ],
      );
    }

    final match = _match;
    if (match == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: title),
            StatusBadge(label: match.label, color: _labelColor(match.score)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(VitheyRadii.card),
            border: Border.all(color: context.appColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${match.score}',
                    style: context.text.titleLarge?.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _labelColor(match.score),
                      height: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 2, bottom: 2),
                    child: Text('/100', style: context.text.labelMedium),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: match.score / 100,
                        minHeight: 8,
                        backgroundColor:
                            context.appColors.muted.withValues(alpha: 0.15),
                        valueColor:
                            AlwaysStoppedAnimation(_labelColor(match.score)),
                      ),
                    ),
                  ),
                ],
              ),
              if (match.matchedSkills.isNotEmpty) ...[
                const SizedBox(height: 12),
                _chipRow(
                  context,
                  label: 'Matched skills',
                  skills: match.matchedSkills,
                  color: AppColors.success,
                  icon: LucideIcons.check,
                ),
              ],
              if (match.gapSkills.isNotEmpty) ...[
                const SizedBox(height: 10),
                _chipRow(
                  context,
                  label: 'Skills to grow',
                  skills: match.gapSkills,
                  color: AppColors.warning,
                  icon: LucideIcons.trendingUp,
                ),
              ],
              const SizedBox(height: 12),
              ...match.reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason,
                          style: context.text.labelMedium?.copyWith(
                            fontSize: 12.5,
                            height: 1.4,
                            color: context.appColors.heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  VitheyIcon(
                    LucideIcons.lightbulb,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  VitheyTextLink(
                    label: 'Ask Vithey AI how to improve',
                    fontSize: 12.5,
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: _askHowToImprove,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            VitheyIcon(LucideIcons.info, size: 13, color: context.appColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                match.disclaimer,
                style: context.text.labelSmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _chipRow(
    BuildContext context, {
    required String label,
    required List<String> skills,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.text.labelMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: skills
              .map((skill) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: color.withValues(alpha: 0.35)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        VitheyIcon(icon, size: 12, color: color),
                        const SizedBox(width: 4),
                        Text(
                          skill,
                          style: context.text.labelSmall?.copyWith(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Color _labelColor(int score) => switch (score) {
        >= 80 => AppColors.success,
        >= 65 => AppColors.primary,
        >= 45 => AppColors.warning,
        _ => AppColors.error,
      };
}
