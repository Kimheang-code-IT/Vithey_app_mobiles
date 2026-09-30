import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/ai_feed_recommendation.dart';

/// Block 2 — Smart Feed mock data (AI-FEED-01…08).
///
/// Ranked recommendations for the logged-in user (`mock-user`, Poster/HR with
/// an IT-leaning skill profile + seeded applied jobs). Apply-eligible jobs with
/// skill overlap are boosted to the top (AI-FEED-04) so Apply CV can be tested
/// straight from a cold start.
abstract final class AiFeedFixtures {
  /// Mock interest profile for the current user (AI-FEED-01): skills, applied
  /// jobs and follows. Later replaced by a real `/ai/feed/recommendations`
  /// call — the shape stays the same.
  static const userInterestSkills = [
    'Flutter',
    'Dart',
    'React',
    'HTML',
    'Java',
    'PostgreSQL',
  ];

  /// Ranked post recommendations, best first (AI-FEED-02/03).
  ///
  /// Mixes personalized jobs with light social/explore entries to avoid a
  /// filter bubble. Relevance is 0–100. `limit` caps the result (AI-FEED-08
  /// cache lives in the repository, not here).
  static List<AiFeedRecommendation> forYou({int limit = 20}) {
    final ranked = _ranked;
    if (limit >= ranked.length) return List.of(ranked);
    return ranked.take(limit).toList();
  }

  static const List<AiFeedRecommendation> _ranked = [
    // Skill-matched, apply-eligible open jobs first (AI-FEED-04).
    AiFeedRecommendation(
      postId: MockIds.post19,
      relevance: 96,
      reason: 'Because your skills include Flutter & Dart',
    ),
    AiFeedRecommendation(
      postId: MockIds.post10,
      relevance: 88,
      reason: 'Matches your React & HTML skills',
    ),
    AiFeedRecommendation(
      postId: MockIds.post20,
      relevance: 81,
      reason: 'Popular with students in your major',
    ),
    // Applied-job updates (AI-FEED-06 explanation variants).
    AiFeedRecommendation(
      postId: MockIds.post3,
      relevance: 62,
      reason: 'Update from a job you applied to',
    ),
    AiFeedRecommendation(
      postId: MockIds.post17,
      relevance: 55,
      reason: 'Update from a job you applied to',
    ),
    // Light social / explore mix (AI-FEED-03).
    AiFeedRecommendation(
      postId: MockIds.post1,
      relevance: 48,
      reason: 'Because you follow this author',
    ),
    AiFeedRecommendation(
      postId: MockIds.post11,
      relevance: 42,
      reason: 'Popular in your network',
    ),
  ];
}
