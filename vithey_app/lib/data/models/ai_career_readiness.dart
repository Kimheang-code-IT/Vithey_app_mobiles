import 'package:aub_connect_app/data/models/ai_skill_score.dart';

/// Overall career readiness (Block 4 — AI-SK-03, AI-SK-04).
///
/// Aggregate of per-skill AI scores plus top-3 improvement suggestions.
class AiCareerReadiness {
  const AiCareerReadiness({
    required this.overallScore,
    required this.topSkills,
    required this.suggestions,
  });

  /// Overall readiness 0–100 (weighted from per-skill AI scores).
  final int overallScore;

  /// Per-skill scores, strongest first.
  final List<AiSkillScore> topSkills;

  /// Up to 3 next skills to improve (AI-SK-04).
  final List<String> suggestions;
}
