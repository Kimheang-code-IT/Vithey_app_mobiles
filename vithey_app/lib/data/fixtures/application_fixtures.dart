import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/modules/jobs/models/application_detail_model.dart';

/// Mock job-application usage (no role picker — usage-shaped):
/// - Logged-in user (Khorn Molika) = **Poster (HR)**: owns JOB posts; Applied Jobs
///   seeds **4** rows (Pending / Review / Accepted / Rejected) for UI demos.
/// - `post-10` stays open (not seeded) so Home → Apply CV still works.
/// - `author-1` (Heng Liza) = **Applier (Student)**: applies to jobs; has no JOB posts.
abstract final class ApplicationFixtures {
  static const _lizaCvFileName = 'Heng_Liza_CV.pdf';
  static final _hrCvFileName =
      '${MockIdentities.mockUserFullName.replaceAll(' ', '_')}_CV.pdf';

  /// Job posts the logged-in user has already applied to (excludes Apply CV demo).
  static Set<String> seedAppliedJobPostIds() => {
        MockIds.post3,
        MockIds.post4,
        MockIds.post17,
        MockIds.post18,
      };

  static Map<String, ApplicationDetailModel> buildApplicationDetails() {
    return {
      // —— Applicants on Poster-owned jobs ——
      MockIds.app1: ApplicationDetailModel(
        applicationId: MockIds.app1,
        jobPostId: MockIds.post7,
        jobTitle: 'Call Center Officer',
        organization: 'LOLC (Cambodia) Plc.',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(1),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
        applicantHeadline: 'Web Developer',
        applicantLocation: 'Pur Senchey, Phnom Penh',
        applicantEmail: 'hengliza81@gmail.com',
      ),
      MockIds.app2: ApplicationDetailModel(
        applicationId: MockIds.app2,
        jobPostId: MockIds.post7,
        jobTitle: 'Call Center Officer',
        organization: 'LOLC (Cambodia) Plc.',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(2),
        reviewStartedAt: MockClock.daysAgo(1),
        cvFileName: 'Sreynich_Chan_CV.pdf',
        applicantUserId: MockIds.author4,
        applicantName: 'Sreynich Chan',
        applicantHeadline: 'Business student',
        applicantLocation: 'Phnom Penh',
        applicantEmail: 'sreynich@example.com',
      ),
      MockIds.appMy1: ApplicationDetailModel(
        applicationId: MockIds.appMy1,
        jobPostId: MockIds.post9,
        jobTitle: 'Marketing Intern',
        organization: 'KDSB',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(3),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
      ),
      MockIds.appMy2: ApplicationDetailModel(
        applicationId: MockIds.appMy2,
        jobPostId: MockIds.post8,
        jobTitle: 'Young Talent, Finance',
        organization: 'Chip Mong Group',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(5),
        reviewStartedAt: MockClock.daysAgo(4),
        cvFileName: 'Heng_Liza_CV.pdf',
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
      ),
      MockIds.appMy3: ApplicationDetailModel(
        applicationId: MockIds.appMy3,
        jobPostId: MockIds.post3,
        jobTitle: 'Frontend Developer',
        organization: 'Chip Mong Group',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.hoursAgo(20),
        cvFileName: _lizaCvFileName,
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
        applicantHeadline: 'Web Developer',
        applicantLocation: 'Pur Senchey, Phnom Penh',
        applicantEmail: 'hengliza81@gmail.com',
      ),
      MockIds.appMy4: ApplicationDetailModel(
        applicationId: MockIds.appMy4,
        jobPostId: MockIds.post4,
        jobTitle: 'Sales (Credit Officer) Intern',
        organization: 'KDSB',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(1),
        reviewStartedAt: MockClock.hoursAgo(12),
        cvFileName: _lizaCvFileName,
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
        applicantHeadline: 'Web Developer',
        applicantLocation: 'Pur Senchey, Phnom Penh',
        applicantEmail: 'hengliza81@gmail.com',
      ),
      MockIds.appMy5: ApplicationDetailModel(
        applicationId: MockIds.appMy5,
        jobPostId: MockIds.post3,
        jobTitle: 'Frontend Developer',
        organization: 'Chip Mong Group',
        status: ApplicationStatus.accepted,
        appliedAt: MockClock.daysAgo(10),
        reviewStartedAt: MockClock.daysAgo(8),
        decidedAt: MockClock.daysAgo(6),
        reviewerNote:
            'Thank you for your interest. Please check your email to receive interview time and location.',
        cvFileName: _lizaCvFileName,
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
        applicantHeadline: 'Web Developer',
        applicantLocation: 'Pur Senchey, Phnom Penh',
        applicantEmail: 'hengliza81@gmail.com',
      ),
      MockIds.appMy6: ApplicationDetailModel(
        applicationId: MockIds.appMy6,
        jobPostId: MockIds.post10,
        jobTitle: 'Web Developer',
        organization: 'Aeon Mall',
        status: ApplicationStatus.rejected,
        appliedAt: MockClock.daysAgo(14),
        reviewStartedAt: MockClock.daysAgo(12),
        decidedAt: MockClock.daysAgo(9),
        reviewerNote:
            "Thank you for your interest. I'm so sorry to inform you didn't pass our selection. However, we openly welcome you again next time.",
        cvFileName: _lizaCvFileName,
        applicantUserId: MockIds.author1,
        applicantName: 'Heng Liza',
        applicantHeadline: 'Web Developer',
        applicantLocation: 'Pur Senchey, Phnom Penh',
        applicantEmail: 'hengliza81@gmail.com',
      ),

      // —— Logged-in Poster Applied Jobs (Profile tab) ——
      MockIds.appHr1: ApplicationDetailModel(
        applicationId: MockIds.appHr1,
        jobPostId: MockIds.post3,
        jobTitle: 'Frontend Developer',
        organization: 'Chip Mong Group',
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(2),
        cvFileName: _hrCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
        applicantHeadline: 'HR & Talent Lead',
        applicantLocation: 'Phnom Penh',
        applicantEmail: MockIdentities.mockUserEmail,
      ),
      MockIds.appHr2: ApplicationDetailModel(
        applicationId: MockIds.appHr2,
        jobPostId: MockIds.post4,
        jobTitle: 'Sales (Credit Officer) Intern',
        organization: 'KDSB',
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(6),
        reviewStartedAt: MockClock.daysAgo(4),
        cvFileName: _hrCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
        applicantHeadline: 'HR & Talent Lead',
        applicantLocation: 'Phnom Penh',
        applicantEmail: MockIdentities.mockUserEmail,
      ),
      MockIds.appHr3: ApplicationDetailModel(
        applicationId: MockIds.appHr3,
        jobPostId: MockIds.post17,
        jobTitle: 'UI/UX Designer',
        organization: 'Smart Axiata',
        status: ApplicationStatus.accepted,
        appliedAt: MockClock.daysAgo(12),
        reviewStartedAt: MockClock.daysAgo(10),
        decidedAt: MockClock.daysAgo(7),
        reviewerNote:
            'Thank you for your interest. Please check your email to receive interview time and location.',
        cvFileName: _hrCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
        applicantHeadline: 'HR & Talent Lead',
        applicantLocation: 'Phnom Penh',
        applicantEmail: MockIdentities.mockUserEmail,
      ),
      MockIds.appHr4: ApplicationDetailModel(
        applicationId: MockIds.appHr4,
        jobPostId: MockIds.post18,
        jobTitle: 'Content Marketing Associate',
        organization: 'Wing Bank',
        status: ApplicationStatus.rejected,
        appliedAt: MockClock.daysAgo(18),
        reviewStartedAt: MockClock.daysAgo(15),
        decidedAt: MockClock.daysAgo(11),
        reviewerNote:
            "Thank you for your interest. I'm so sorry to inform you didn't pass our selection. However, we openly welcome you again next time.",
        cvFileName: _hrCvFileName,
        applicantUserId: MockIds.currentUser,
        applicantName: MockIdentities.mockUserFullName,
        applicantHeadline: 'HR & Talent Lead',
        applicantLocation: 'Phnom Penh',
        applicantEmail: MockIdentities.mockUserEmail,
      ),
    };
  }

  static List<JobApplicationModel> defaultApplicants() {
    return [
      JobApplicationModel(
        id: MockIds.app1,
        jobPostId: MockIds.post7,
        applicantName: 'Heng Liza',
        applicantUserId: MockIds.author1,
        headline: 'Web Developer',
        location: 'Pur Senchey, Phnom Penh',
        email: 'hengliza81@gmail.com',
        appliedAt: MockClock.daysAgo(1),
        cvFileName: 'Heng_Liza_CV.pdf',
        rank: 1,
      ),
      JobApplicationModel(
        id: MockIds.app2,
        jobPostId: MockIds.post7,
        applicantName: 'Sreynich Chan',
        applicantUserId: MockIds.author4,
        headline: 'Business student',
        location: 'Phnom Penh',
        email: 'sreynich@example.com',
        appliedAt: MockClock.daysAgo(2),
        cvFileName: 'Sreynich_Chan_CV.pdf',
        status: ApplicationStatus.reviewed,
        rank: 2,
      ),
    ];
  }

  /// Applicants on Poster-owned jobs (and optional other listings).
  static Map<String, List<JobApplicationModel>> buildApplicantsByJob() {
    final onCallCenter = defaultApplicants();
    final onFinance = [
      JobApplicationModel(
        id: MockIds.appMy2,
        jobPostId: MockIds.post8,
        applicantName: 'Heng Liza',
        applicantUserId: MockIds.author1,
        headline: 'Web Developer',
        location: 'Pur Senchey, Phnom Penh',
        email: 'hengliza81@gmail.com',
        appliedAt: MockClock.daysAgo(5),
        cvFileName: 'Heng_Liza_CV.pdf',
        status: ApplicationStatus.reviewed,
        rank: 1,
      ),
    ];
    final onMarketing = [
      JobApplicationModel(
        id: MockIds.appMy1,
        jobPostId: MockIds.post9,
        applicantName: 'Heng Liza',
        applicantUserId: MockIds.author1,
        headline: 'Web Developer',
        location: 'Pur Senchey, Phnom Penh',
        email: 'hengliza81@gmail.com',
        appliedAt: MockClock.daysAgo(3),
        cvFileName: 'Heng_Liza_CV.pdf',
        rank: 1,
      ),
    ];
    return {
      MockIds.post7: onCallCenter,
      MockIds.post8: onFinance,
      MockIds.post9: onMarketing,
    };
  }

  /// Logged-in Poster — 4 Applied Jobs covering all status pills.
  static List<AppliedJobSummary> myAppliedJobs() {
    return [
      AppliedJobSummary(
        id: MockIds.appHr1,
        jobPostId: MockIds.post3,
        jobTitle: 'Frontend Developer',
        company: 'Chip Mong Group',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost1,
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(2),
      ),
      AppliedJobSummary(
        id: MockIds.appHr2,
        jobPostId: MockIds.post4,
        jobTitle: 'Sales (Credit Officer) Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'KDSB Branches & Head Office',
        mediaUrl: AppAssets.jobPost2,
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(6),
      ),
      AppliedJobSummary(
        id: MockIds.appHr3,
        jobPostId: MockIds.post17,
        jobTitle: 'UI/UX Designer',
        company: 'Smart Axiata',
        employmentType: 'Full-time',
        location: 'Phnom Penh',
        mediaUrl: AppAssets.jobPost3,
        status: ApplicationStatus.accepted,
        appliedAt: MockClock.daysAgo(12),
      ),
      AppliedJobSummary(
        id: MockIds.appHr4,
        jobPostId: MockIds.post18,
        jobTitle: 'Content Marketing Associate',
        company: 'Wing Bank',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Toul Kork',
        mediaUrl: AppAssets.jobPost2,
        status: ApplicationStatus.rejected,
        appliedAt: MockClock.daysAgo(18),
      ),
    ];
  }

  /// Student (Heng Liza) — Applied Jobs covering all statuses for UI review.
  static List<AppliedJobSummary> applierAppliedJobs() {
    return [
      AppliedJobSummary(
        id: MockIds.appMy1,
        jobPostId: MockIds.post9,
        jobTitle: 'Marketing Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost2,
        status: ApplicationStatus.pending,
        appliedAt: MockClock.daysAgo(3),
      ),
      AppliedJobSummary(
        id: MockIds.appMy2,
        jobPostId: MockIds.post8,
        jobTitle: 'Young Talent, Finance',
        company: 'Chip Mong Group',
        employmentType: 'Internship',
        location: 'Phnom Penh',
        mediaUrl: AppAssets.jobPost1,
        status: ApplicationStatus.reviewed,
        appliedAt: MockClock.daysAgo(5),
      ),
      AppliedJobSummary(
        id: MockIds.appMy5,
        jobPostId: MockIds.post3,
        jobTitle: 'Frontend Developer',
        company: 'Chip Mong Group',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost1,
        status: ApplicationStatus.accepted,
        appliedAt: MockClock.daysAgo(10),
      ),
      AppliedJobSummary(
        id: MockIds.appMy6,
        jobPostId: MockIds.post10,
        jobTitle: 'Web Developer',
        company: 'Aeon Mall',
        employmentType: 'Full-time',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost1,
        status: ApplicationStatus.rejected,
        appliedAt: MockClock.daysAgo(14),
      ),
    ];
  }

  static List<AppliedJobSummary> appliedJobsFor(String userId) {
    if (userId == MockIds.author1) return applierAppliedJobs();
    if (userId == MockIds.currentUser) return myAppliedJobs();
    return const [];
  }

  static List<ApplicantExperienceEntry> experienceFor(String userId) {
    if (userId == MockIds.author1) {
      return const [
        ApplicantExperienceEntry(
          title: 'Barista & Social Media',
          organization: 'Koala Coffee',
          period: '2024 - Present',
          description:
              'Creates drink specials, manages social content, and supports weekend pop-up events.',
        ),
      ];
    }
    return const [
      ApplicantExperienceEntry(
        title: 'Marketing Intern',
        organization: 'Aeon Mall',
        period: '2024 - Present',
        description:
            'Supported campaign analytics and social content for youth-focused retail events.',
      ),
    ];
  }

  static List<ApplicantEducationEntry> educationFor(String userId) {
    if (userId == MockIds.author1) {
      return const [
        ApplicantEducationEntry(
          degree: 'BACII Certificate',
          school: 'Champuvorn High School',
          period: '2017 - 2023',
        ),
        ApplicantEducationEntry(
          degree: 'Computer Science and Engineering',
          school: 'Acleda University and Business',
          period: '2024 - Present',
        ),
      ];
    }
    return const [
      ApplicantEducationEntry(
        degree: 'B.A. Marketing',
        school: 'American University of Phnom Penh',
        period: '2022 - 2026',
      ),
    ];
  }
}
