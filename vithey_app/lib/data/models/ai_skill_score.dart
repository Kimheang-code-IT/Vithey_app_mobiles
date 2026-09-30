/// AI-scored single skill (Block 4 — Skill Score).
///
/// [aiScore] is derived from activity signals and linked proof attachments.
/// [selfPercent] is kept for API compatibility and mirrors the AI score
/// (manual self-rating was removed).
class AiSkillScore {
  const AiSkillScore({
    required this.skillName,
    required this.selfPercent,
    required this.aiScore,
    this.signals = const [],
  });

  final String skillName;

  /// Legacy field — same as [aiScore] (self-rating UI removed).
  final int selfPercent;

  /// AI score (0–100) from signals + attachments.
  final int aiScore;

  /// Human-readable evidence lines, e.g. "2 related posts".
  final List<String> signals;
}
