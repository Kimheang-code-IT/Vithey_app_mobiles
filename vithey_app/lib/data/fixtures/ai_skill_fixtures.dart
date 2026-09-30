import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_career_readiness.dart';
import 'package:aub_connect_app/data/models/ai_skill_score.dart';
import 'package:aub_connect_app/data/models/ai_skill_scorer.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

/// Mock Skill Score data (Block 4 — AI-SK-02…04, AI-SK-07).
///
/// Scores are AI-derived from skill name + linked attachments + activity
/// signals — no manual self-rating.
abstract final class AiSkillFixtures {
  static int mockAiScore(ProfileSkill skill) => AiSkillScorer.scoreSkill(skill);

  static List<String> _signalsFor(ProfileSkill skill) {
    final posts = AiSkillScorer.activitySignals[skill.name] ?? 0;
    final attachments = skill.attachmentPaths.length;
    return <String>[
      '$posts related post${posts == 1 ? '' : 's'}',
      if (attachments > 0)
        '$attachments linked attachment${attachments == 1 ? '' : 's'}',
      if (posts >= 2) 'Chat practice detected',
    ];
  }

  /// Per-skill AI scores (strongest first). Pass [skills] to score the live
  /// profile; otherwise falls back to fixture current user.
  static List<AiSkillScore> skillScores([List<ProfileSkill>? skills]) {
    final list = skills ??
        UserFixtures.buildProfiles()[MockIds.currentUser]?.skills ??
        const <ProfileSkill>[];
    final scores = <AiSkillScore>[
      for (final skill in list)
        AiSkillScore(
          skillName: skill.name,
          selfPercent: mockAiScore(skill),
          aiScore: mockAiScore(skill),
          signals: _signalsFor(skill),
        ),
    ];
    scores.sort((a, b) => b.aiScore.compareTo(a.aiScore));
    return scores;
  }

  /// Overall career readiness (AI-SK-03, AI-SK-04).
  static AiCareerReadiness readinessForCurrentUser([
    List<ProfileSkill>? skills,
  ]) {
    final scores = skillScores(skills);
    final overall = scores.isEmpty
        ? 0
        : (scores.fold<int>(0, (sum, s) => sum + s.aiScore) / scores.length)
            .round();
    final weakest = [...scores]..sort((a, b) => a.aiScore.compareTo(b.aiScore));
    return AiCareerReadiness(
      overallScore: overall,
      topSkills: scores,
      suggestions: [
        for (final s in weakest.take(3))
          'Practice ${s.skillName} — AI score ${s.aiScore}%',
      ],
    );
  }
}
