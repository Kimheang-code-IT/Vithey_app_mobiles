import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/status_badge.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/ai_job_match_result.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Apply Review — AI match card (Block 5, AI-JOB-07).
///
/// One card, not a dashboard: score + label, matched skills, gaps, 3–5
/// reasons and the mandatory disclaimer (AI-JOB-13). Loads the mock match
/// via `AiRepository.matchJob` when the Review step opens. Gating with
/// `FeatureFlags.useAiJobMatch` is done by the caller.
class JobMatchScoreCard extends StatefulWidget {
  const JobMatchScoreCard({
    super.key,
    required this.jobPostId,
    this.jobTitle,
  });

  final String jobPostId;
  final String? jobTitle;

  @override
  State<JobMatchScoreCard> createState() => _JobMatchScoreCardState();
}

class _JobMatchScoreCardState extends State<JobMatchScoreCard> {
  AiJobMatchResult? _match;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await Get.find<AiRepository>()
          .matchJob(jobPostId: widget.jobPostId);
      if (!mounted) return;
      setState(() => _match = result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = 'Match score is unavailable right now.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _improveMatch() {
    // Deep-link prompt into the Vithey AI chat (AI-JOB-10) — the chatbot
    // accepts a String argument as starter prompt.
    final jobTitle = widget.jobTitle;
    final prompt = jobTitle == null || jobTitle.isEmpty
        ? 'How can I improve my match score for this job?'
        : 'How can I improve my match score for the $jobTitle role?';
    Get.toNamed(AppRoutes.chatbot, arguments: prompt);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.appColors.border),
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_loading) {
      return Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Text(
            'Vithey AI is checking your match…',
            style: context.text.bodySmall,
          ),
        ],
      );
    }

    final match = _match;
    if (_error != null || match == null) {
      return Text(
        _error ?? 'Match score is unavailable right now.',
        style: context.text.bodySmall?.copyWith(color: AppColors.error),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            VitheyIcon(LucideIcons.sparkles,
                size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'AI Match Score',
                style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            StatusBadge(label: match.label, color: _labelColor(match.label)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${match.score}',
              style: context.text.titleLarge?.copyWith(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: _scoreColor(match.score),
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 2),
              child: Text(
                '/100',
                style: context.text.bodySmall,
              ),
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
                  valueColor: AlwaysStoppedAnimation(_scoreColor(match.score)),
                ),
              ),
            ),
          ],
        ),
        if (match.incompleteProfile) ...[
          const SizedBox(height: 12),
          _addSkillsHint(context),
        ] else ...[
          const SizedBox(height: 14),
          _skillsSection(context),
        ],
        const SizedBox(height: 14),
        _reasonsSection(context, match),
        const SizedBox(height: 12),
        Row(
          children: [
            VitheyIcon(
              LucideIcons.lightbulb,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 4),
            VitheyTextLink(
              label: 'Improve match with Vithey AI',
              fontSize: 12.5,
              color: Theme.of(context).colorScheme.primary,
              onPressed: _improveMatch,
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            VitheyIcon(LucideIcons.info,
                size: 13, color: context.appColors.muted),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                match.disclaimer,
                style: context.text.bodySmall?.copyWith(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _addSkillsHint(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const VitheyIcon(LucideIcons.circlePlus,
              size: 18, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Add skills to your profile to improve your match score.',
              style: context.text.labelMedium?.copyWith(
                color: context.appColors.heading,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skillsSection(BuildContext context) {
    final match = _match!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (match.matchedSkills.isNotEmpty) ...[
          Text(
            'Matched skills',
            style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: match.matchedSkills
                .map((skill) => _SkillChip(
                      label: skill,
                      color: AppColors.success,
                    ))
                .toList(),
          ),
        ],
        if (match.gapSkills.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            'Skills to grow',
            style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: match.gapSkills
                .map((skill) => _SkillChip(
                      label: skill,
                      color: AppColors.warning,
                      dashed: true,
                    ))
                .toList(),
          ),
        ],
      ],
    );
  }

  Widget _reasonsSection(BuildContext context, AiJobMatchResult match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Why this score',
          style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
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
                    style: context.text.bodyMedium?.copyWith(fontSize: 12.5, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Color _labelColor(String label) => switch (label) {
        'Excellent' => AppColors.success,
        'Good' => AppColors.primary,
        'Fair' => AppColors.warning,
        _ => AppColors.error,
      };

  Color _scoreColor(int score) => switch (score) {
        >= 80 => AppColors.success,
        >= 65 => AppColors.primary,
        >= 45 => AppColors.warning,
        _ => AppColors.error,
      };
}

class _SkillChip extends StatelessWidget {
  const _SkillChip({required this.label, required this.color, this.dashed});

  final String label;
  final Color color;
  final bool? dashed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: dashed == true ? 0.08 : 0.14),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          VitheyIcon(
            dashed == true ? LucideIcons.trendingUp : LucideIcons.check,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: context.text.labelSmall?.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
