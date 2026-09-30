import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/ai_cv_draft.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

/// Mock Auto-Create CV drafts built only from profile fixture data (AI-CV-07).
abstract final class AiCvFixtures {
  static AiCvDraft draftForCurrentUser() {
    final profile = UserFixtures.buildProfiles()[MockIds.currentUser];
    if (profile == null) {
      return const AiCvDraft(
        fullName: '',
        summary: '',
        skills: [],
        education: [],
        experience: [],
        projects: [],
        contact: '',
        incompleteProfile: true,
        incompleteMessage:
            'Complete your profile first so Vithey AI can build your CV.',
      );
    }
    return fromProfile(profile);
  }

  static AiCvDraft fromProfile(UserProfileModel profile) {
    final skills = profile.skills.map((s) => s.name).where((n) => n.trim().isNotEmpty).toList();
    final education = profile.educationEntries.isNotEmpty
        ? profile.educationEntries.map((e) {
            final major = e.major?.trim();
            final cert = e.certificate?.trim();
            final parts = <String>[
              e.school,
              if (major != null && major.isNotEmpty) major,
              if (cert != null && cert.isNotEmpty) cert,
            ];
            return parts.join(' · ');
          }).toList()
        : profile.education;

    final experience = profile.workEntries.map((w) {
      final workplace = w.workplace.trim();
      final position = w.position.trim();
      if (workplace.isNotEmpty && position.isNotEmpty) {
        return '$position at $workplace';
      }
      if (position.isNotEmpty) return position;
      return workplace;
    }).where((line) => line.isNotEmpty).toList();

    final bio = profile.bio?.trim() ?? '';
    final projects = <String>[
      if (profile.portfolioUrl != null && profile.portfolioUrl!.isNotEmpty)
        'Portfolio — ${profile.portfolioUrl}',
      if (bio.isNotEmpty) 'Personal note — $bio',
    ];

    final contactParts = <String>[
      if (profile.email != null && profile.email!.isNotEmpty) profile.email!,
      if (profile.phone != null && profile.phone!.isNotEmpty) profile.phone!,
      if (profile.location != null && profile.location!.isNotEmpty)
        profile.location!,
    ];

    final incomplete = profile.fullName.trim().isEmpty ||
        (education.isEmpty && experience.isEmpty && skills.isEmpty);

    final major = profile.major?.trim();
    final university = profile.university?.trim();
    final summary = _summaryFrom(
      profile: profile,
      major: major,
      university: university,
      bio: bio,
    );

    return AiCvDraft(
      fullName: profile.fullName.isNotEmpty
          ? profile.fullName
          : MockIdentities.mockUserFullName,
      summary: summary,
      skills: skills,
      education: education,
      experience: experience,
      projects: projects,
      contact: contactParts.join(' · '),
      incompleteProfile: incomplete,
      incompleteMessage: incomplete
          ? 'Your profile looks incomplete. Add education, experience, or skills, then try again.'
          : null,
    );
  }

  /// Builds a summary sentence from profile facts only (AI-CV-01/07).
  static String _summaryFrom({
    required UserProfileModel profile,
    required String? major,
    required String? university,
    required String bio,
  }) {
    final summaryBits = <String>[
      if (major != null && major.isNotEmpty) major,
      if (university != null && university.isNotEmpty) 'student at $university',
      if (profile.workplace != null && profile.workplace!.isNotEmpty)
        'currently at ${profile.workplace}',
    ];
    if (summaryBits.isEmpty) {
      return bio.isNotEmpty
          ? bio
          : 'Aspiring professional building a career through Vithey.';
    }
    return '${summaryBits.join(', ')}.';
  }

  /// Mock “Regenerate summary”: rotates the profile-fact phrases and may lead
  /// with the user's own top skills. Never invents employers or degrees.
  static String regeneratedSummary({required int variant}) {
    final profile = UserFixtures.buildProfiles()[MockIds.currentUser];
    if (profile == null) {
      return 'Complete your profile so Vithey AI can draft your summary.';
    }
    final major = profile.major?.trim();
    final university = profile.university?.trim();
    final bio = profile.bio?.trim() ?? '';

    final bits = <String>[
      if (major != null && major.isNotEmpty) major,
      if (university != null && university.isNotEmpty) 'student at $university',
      if (profile.workplace != null && profile.workplace!.isNotEmpty)
        'currently at ${profile.workplace}',
    ];
    if (bits.isEmpty) {
      return bio.isNotEmpty
          ? bio
          : 'Aspiring professional building a career through Vithey.';
    }

    final lead = variant % bits.length;
    final ordered = [...bits.skip(lead), ...bits.take(lead)];
    final topSkills = profile.skills
        .map((s) => s.name.trim())
        .where((n) => n.isNotEmpty)
        .take(variant.isEven ? 3 : 0)
        .toList();
    final skillPhrase = topSkills.isEmpty
        ? ''
        : ' Focused on ${topSkills.join(', ')}.';
    return '${ordered.join(', ')}.$skillPhrase';
  }
}
