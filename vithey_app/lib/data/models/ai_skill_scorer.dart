import 'package:aub_connect_app/data/models/user_profile_model.dart';

/// Mock AI skill scoring — used when creating/updating skills and on Profile
/// career readiness. No manual self-rating; score comes from activity signals
/// plus linked proof attachments.
abstract final class AiSkillScorer {
  /// Related-post / practice counts (mock signals).
  static const activitySignals = <String, int>{
    'Flutter': 3,
    'HTML': 1,
    'Spring Boot': 2,
    'React': 4,
    'Dart': 2,
    'Java': 2,
    'PostgreSQL': 1,
    'Docker': 0,
  };

  /// Deterministic 0–100 score from skill name + linked attachments.
  static int score({
    required String name,
    List<String> attachmentPaths = const [],
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 0;
    final posts = activitySignals[trimmed] ?? 0;
    final seed = trimmed.toLowerCase().hashCode.abs() % 18;
    final base = 42 + posts * 8 + seed;
    return (base + attachmentPaths.length * 10).clamp(0, 100);
  }

  static int scoreSkill(ProfileSkill skill) {
    // Coalesce — hot reload / legacy instances may expose a null list field.
    final paths = skill.attachmentPaths;
    return score(
      name: skill.name,
      attachmentPaths: paths,
    );
  }
}
