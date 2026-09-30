import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_job_match_result.dart';

/// Mock Job Match scores (Block 5) — rule-based skill overlap only (AI-JOB-12).
///
/// No network calls. Later swap to `AiService.matchJob` without touching
/// screens: keep `matchForJob`, `match` and `scoreForApplicant` signatures.
abstract final class AiJobMatchFixtures {
  /// Required skills per demo job post (AI-JOB-02 mock — job fields embedded).
  static const _jobSkills = <String, List<String>>{
    MockIds.post10: ['HTML', 'CSS', 'JavaScript', 'React', 'Git'],
    MockIds.post19: ['Flutter', 'Dart', 'REST API', 'Git'],
    MockIds.post20: ['SQL', 'PostgreSQL', 'Excel', 'Python'],
    MockIds.post7: ['Communication', 'English', 'Customer Service', 'MS Office'],
    MockIds.post8: ['Finance', 'Excel', 'Accounting', 'English'],
    MockIds.post9: ['Marketing', 'Content Writing', 'Canva', 'English'],
  };

  static const _defaultSkills = <String>['Communication', 'English'];

  /// Applicant skill names resolved from profile fixtures. Empty for users
  /// without seeded skills — drives the "add skills to improve" copy.
  static List<String> _skillsForUser(String? userId) {
    switch (userId) {
      case MockIds.currentUser:
        return UserFixtures.mockItSkills.map((s) => s.name).toList();
      case MockIds.author1:
        return UserFixtures.lizaMockSkills.map((s) => s.name).toList();
      case MockIds.author2:
        return ['Content Writing', 'Canva', 'Communication', 'English'];
      case MockIds.author4:
        // Business student — no tech overlap with demo dev jobs.
        return ['MS Office', 'English'];
      default:
        return const [];
    }
  }

  /// Rule-based match for the CURRENT user against one job (AI-JOB-01…06).
  /// Used by `AiRepository.matchJob` on the Apply review step.
  static AiJobMatchResult matchForJob({
    required String jobPostId,
    String? cvFileId,
  }) =>
      _build(
        jobPostId: jobPostId,
        applicantUserId: MockIds.currentUser,
        cvFileId: cvFileId,
      );

  /// Rule-based match for ANY applicant against one job — poster side
  /// applicants list / detail (AI-JOB-08/09).
  static AiJobMatchResult match({
    required String jobPostId,
    String? applicantUserId,
  }) =>
      _build(jobPostId: jobPostId, applicantUserId: applicantUserId);

  /// Synchronous mock score for poster applicant lists (AI-JOB-08/09).
  static int scoreForApplicant({
    required String jobPostId,
    String? applicantUserId,
  }) =>
      match(jobPostId: jobPostId, applicantUserId: applicantUserId).score;

  static AiJobMatchResult _build({
    required String jobPostId,
    String? applicantUserId,
    String? cvFileId,
  }) {
    final required = _jobSkills[jobPostId] ?? _defaultSkills;
    final applicantSkills = _skillsForUser(applicantUserId)
        .map((s) => s.toLowerCase())
        .toSet();

    if (applicantSkills.isEmpty) {
      // AI-JOB acceptance: low score + "add skills" copy when skills are empty.
      return AiJobMatchResult(
        jobPostId: jobPostId,
        cvFileId: cvFileId,
        applicantUserId: applicantUserId,
        score: 12,
        label: AiJobMatchResult.labelForScore(12),
        matchedSkills: const [],
        gapSkills: List.unmodifiable(required),
        reasons: const [
          'Your profile has no skills listed yet, so AI cannot compare them '
              'with this job.',
          'Add at least 3 relevant skills to unlock a real match score.',
          'The poster will still see your CV and application note.',
        ],
        incompleteProfile: true,
      );
    }

    final matched = required
        .where((skill) => applicantSkills.contains(skill.toLowerCase()))
        .toList();
    final gaps = required.where((skill) => !matched.contains(skill)).toList();

    // Deterministic rule-based score: skill coverage drives the score.
    var score = ((matched.length / required.length) * 75).round() + 20;
    if (matched.length == required.length) score = 96;
    score = score.clamp(15, 96);

    return AiJobMatchResult(
      jobPostId: jobPostId,
      cvFileId: cvFileId,
      applicantUserId: applicantUserId,
      score: score,
      label: AiJobMatchResult.labelForScore(score),
      matchedSkills: List.unmodifiable(matched),
      gapSkills: List.unmodifiable(gaps),
      reasons: _reasons(matched: matched, gaps: gaps),
    );
  }

  static List<String> _reasons({
    required List<String> matched,
    required List<String> gaps,
  }) {
    final reasons = <String>[];
    if (matched.isNotEmpty) {
      reasons.add(
        'Your skills in ${matched.take(2).join(' and ')} match what this job '
        'is asking for.',
      );
    } else {
      reasons.add(
        'None of your listed skills appear in this job’s requirements yet.',
      );
    }
    if (gaps.isNotEmpty) {
      reasons.add(
        'Learning ${gaps.take(2).join(' or ')} would raise your match '
        'noticeably.',
      );
    } else {
      reasons.add('You cover every skill this job asks for — great job!');
    }
    reasons.add('Your CV and application note are still reviewed by a human.');
    return List.unmodifiable(reasons);
  }
}
