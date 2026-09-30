/// AI Job Match result (Block 5 — AI-JOB-04…07).
///
/// Mock-first shape mirroring the Java `ai-service` job-match contract:
/// score 0–100 + label, matched / gap skills, 3–5 student-friendly reasons
/// and a mandatory transparent disclaimer (AI-JOB-13).
class AiJobMatchResult {
  const AiJobMatchResult({
    required this.jobPostId,
    required this.score,
    required this.label,
    required this.matchedSkills,
    required this.gapSkills,
    required this.reasons,
    this.applicantUserId,
    this.cvFileId,
    this.incompleteProfile = false,
    this.disclaimer = defaultDisclaimer,
  });

  final String jobPostId;

  /// Applicant this score belongs to (poster applicant list / detail).
  final String? applicantUserId;

  /// 0–100 match score (mock: rule-based skill overlap, AI-JOB-12).
  final int score;

  /// Excellent / Good / Fair / Low (AI-JOB-04).
  final String label;

  /// Top matched skills for this job (AI-JOB-05).
  final List<String> matchedSkills;

  /// Missing / weak skills for this job (AI-JOB-05).
  final List<String> gapSkills;

  /// Short student-friendly reasons, no fake claims (AI-JOB-06).
  final List<String> reasons;

  /// Optional CV snapshot used for matching.
  final String? cvFileId;

  /// True when the applicant has no skills on their profile yet —
  /// UI must show "add skills to improve" copy (AI-JOB acceptance).
  final bool incompleteProfile;

  /// Always rendered with the score (AI-JOB-13).
  final String disclaimer;

  static const defaultDisclaimer = 'AI assist only — not a hiring decision.';

  static String labelForScore(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 65) return 'Good';
    if (score >= 50) return 'Fair';
    return 'Low';
  }
}
