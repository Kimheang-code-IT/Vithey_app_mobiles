import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/fixtures/application_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/job_application_service.dart';
import 'package:aub_connect_app/modules/jobs/models/application_detail_model.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_result.dart';

enum JobEligibility {
  eligible,
  alreadyApplied,
  ownJob,
  closed,
  notFound,
  notJob,
}

class JobEligibilityResult {
  const JobEligibilityResult({
    required this.eligibility,
    this.job,
    this.message,
    this.existingApplicationId,
  });

  final JobEligibility eligibility;
  final FeedPost? job;
  final String? message;
  final String? existingApplicationId;
}

class JobApplicationRepository {
  JobApplicationRepository(
    this._postRepository,
    this._applicationService,
    this._flags,
    this._localStorage,
  );

  final PostRepository _postRepository;
  final JobApplicationService _applicationService;
  final FeatureFlags _flags;
  final LocalStorageService _localStorage;

  static final _mockAppliedJobs = <String>{};
  static final _mockApplicationDetails = <String, ApplicationDetailModel>{};
  static final _mockSubmittedApplicationIds = <String>{};
  static const _mockSeedVersion = 5;
  static int _loadedMockSeedVersion = 0;
  static Future<void>? _mockSeedFuture;

  bool get useMockApi => _flags.useMockApi;

  Future<void> _ensureMockSeed() async {
    if (_loadedMockSeedVersion == _mockSeedVersion) return;
    _mockSeedFuture ??= _loadMockSeed();
    await _mockSeedFuture;
  }

  /// Demo: restore apply / status overrides before screens load.
  Future<void> hydrateMockState() => _ensureMockSeed();

  Future<void> _loadMockSeed() async {
    if (_loadedMockSeedVersion == _mockSeedVersion) return;
    _mockAppliedJobs
      ..clear()
      ..addAll(ApplicationFixtures.seedAppliedJobPostIds());
    _mockApplicationDetails
      ..clear()
      ..addAll(ApplicationFixtures.buildApplicationDetails());
    _mockSubmittedApplicationIds.clear();

    final persistedApplied = await _localStorage.readMockAppliedJobIds();
    _mockAppliedJobs.addAll(persistedApplied);

    final submitted = await _localStorage.readMockSubmittedApplications();
    for (final raw in submitted) {
      final detail = _detailFromJson(raw);
      if (detail == null) continue;
      _mockApplicationDetails[detail.applicationId] = detail;
      _mockAppliedJobs.add(detail.jobPostId);
      _mockSubmittedApplicationIds.add(detail.applicationId);
    }

    final statuses = await _localStorage.readMockApplicationStatuses();
    for (final entry in statuses.entries) {
      final status = _statusFromName(entry.value);
      if (status == null) continue;
      _applyStatusInMemory(entry.key, status);
    }

    _loadedMockSeedVersion = _mockSeedVersion;
  }

  /// Clears in-memory mock apply state (useful after hot reload).
  static void resetMockApplyState() {
    _loadedMockSeedVersion = 0;
    _mockSeedFuture = null;
    _mockAppliedJobs.clear();
    _mockApplicationDetails.clear();
    _mockSubmittedApplicationIds.clear();
  }

  ApplicationStatus? _statusFromName(String name) {
    for (final status in ApplicationStatus.values) {
      if (status.name == name) return status;
    }
    return null;
  }

  ApplicationDetailModel? _detailFromJson(Map<String, dynamic> raw) {
    final applicationId = raw['applicationId']?.toString();
    final jobPostId = raw['jobPostId']?.toString();
    final jobTitle = raw['jobTitle']?.toString();
    final appliedAtRaw = raw['appliedAt']?.toString();
    final status = _statusFromName(raw['status']?.toString() ?? '');
    if (applicationId == null ||
        jobPostId == null ||
        jobTitle == null ||
        appliedAtRaw == null ||
        status == null) {
      return null;
    }
    return ApplicationDetailModel(
      applicationId: applicationId,
      jobPostId: jobPostId,
      jobTitle: jobTitle,
      organization: raw['organization']?.toString(),
      status: status,
      appliedAt: DateTime.tryParse(appliedAtRaw) ?? DateTime.now(),
      reviewStartedAt: DateTime.tryParse(raw['reviewStartedAt']?.toString() ?? ''),
      decidedAt: DateTime.tryParse(raw['decidedAt']?.toString() ?? ''),
      reviewerNote: raw['reviewerNote']?.toString(),
      cvFileName: raw['cvFileName']?.toString(),
      applicantUserId: raw['applicantUserId']?.toString(),
      applicantName: raw['applicantName']?.toString(),
      applicantHeadline: raw['applicantHeadline']?.toString(),
      applicantLocation: raw['applicantLocation']?.toString(),
      applicantEmail: raw['applicantEmail']?.toString(),
    );
  }

  Map<String, dynamic> _detailToJson(ApplicationDetailModel detail) {
    return {
      'applicationId': detail.applicationId,
      'jobPostId': detail.jobPostId,
      'jobTitle': detail.jobTitle,
      if (detail.organization != null) 'organization': detail.organization,
      'status': detail.status.name,
      'appliedAt': detail.appliedAt.toIso8601String(),
      if (detail.reviewStartedAt != null)
        'reviewStartedAt': detail.reviewStartedAt!.toIso8601String(),
      if (detail.decidedAt != null)
        'decidedAt': detail.decidedAt!.toIso8601String(),
      if (detail.reviewerNote != null) 'reviewerNote': detail.reviewerNote,
      if (detail.cvFileName != null) 'cvFileName': detail.cvFileName,
      if (detail.applicantUserId != null)
        'applicantUserId': detail.applicantUserId,
      if (detail.applicantName != null) 'applicantName': detail.applicantName,
      if (detail.applicantHeadline != null)
        'applicantHeadline': detail.applicantHeadline,
      if (detail.applicantLocation != null)
        'applicantLocation': detail.applicantLocation,
      if (detail.applicantEmail != null) 'applicantEmail': detail.applicantEmail,
    };
  }

  void _applyStatusInMemory(String applicationId, ApplicationStatus status) {
    final existing = _mockApplicationDetails[applicationId];
    if (existing == null) return;
    final now = DateTime.now();
    _mockApplicationDetails[applicationId] = ApplicationDetailModel(
      applicationId: existing.applicationId,
      jobPostId: existing.jobPostId,
      jobTitle: existing.jobTitle,
      organization: existing.organization,
      status: status,
      appliedAt: existing.appliedAt,
      reviewStartedAt: status != ApplicationStatus.pending
          ? existing.reviewStartedAt ?? now.subtract(const Duration(hours: 6))
          : null,
      decidedAt: status == ApplicationStatus.accepted ||
              status == ApplicationStatus.rejected
          ? existing.decidedAt ?? now
          : null,
      reviewerNote: status == ApplicationStatus.accepted
          ? 'Thank you for your interest. Please check your email to receive interview time and location.'
          : status == ApplicationStatus.rejected
              ? "Thank you for your interest. I'm so sorry to inform you didn't pass our selection. However, we openly welcome you again next time."
              : null,
      cvFileName: existing.cvFileName,
      applicantUserId: existing.applicantUserId,
      applicantName: existing.applicantName,
      applicantHeadline: existing.applicantHeadline,
      applicantLocation: existing.applicantLocation,
      applicantEmail: existing.applicantEmail,
    );
  }

  Future<void> _persistAppliedJobs() async {
    await _localStorage.saveMockAppliedJobIds(_mockAppliedJobs);
  }

  Future<void> _persistSubmittedApplications() async {
    final payload = _mockSubmittedApplicationIds
        .map((id) => _mockApplicationDetails[id])
        .whereType<ApplicationDetailModel>()
        .map(_detailToJson)
        .toList();
    await _localStorage.saveMockSubmittedApplications(payload);
  }

  Future<void> _persistApplicationStatus(
    String applicationId,
    ApplicationStatus status,
  ) async {
    final statuses = await _localStorage.readMockApplicationStatuses();
    statuses[applicationId] = status.name;
    await _localStorage.saveMockApplicationStatuses(statuses);
  }

  Future<JobEligibilityResult> loadJobEligibility(String jobPostId) async {
    if (useMockApi) await _ensureMockSeed();
    final job = await _postRepository.fetchPost(jobPostId);
    if (job == null) {
      return const JobEligibilityResult(
        eligibility: JobEligibility.notFound,
        message: 'This job is no longer available',
      );
    }
    if (job.type != PostType.job) {
      return JobEligibilityResult(
        eligibility: JobEligibility.notJob,
        job: job,
        message: 'This post is not a job listing',
      );
    }
    if (job.isOwnPost) {
      return JobEligibilityResult(
        eligibility: JobEligibility.ownJob,
        job: job,
        message: 'You posted this job. Manage applicants from your profile.',
      );
    }
    if (job.lifecycleState != JobLifecycleState.open) {
      return JobEligibilityResult(
        eligibility: JobEligibility.closed,
        job: job,
        message: 'This job is no longer accepting applications',
      );
    }

    final alreadyAppliedLocally =
        job.applicationState == JobApplicationState.applied ||
            _mockAppliedJobs.contains(jobPostId);
    final appliedOnServer =
        !useMockApi && await _applicationService.hasApplied(jobPostId);

    if (alreadyAppliedLocally || appliedOnServer) {
      final applicationId = await findApplicationIdForJob(jobPostId);
      return JobEligibilityResult(
        eligibility: JobEligibility.alreadyApplied,
        job: job.copyWith(applicationState: JobApplicationState.applied),
        message: 'Application already submitted',
        existingApplicationId: applicationId,
      );
    }

    return JobEligibilityResult(eligibility: JobEligibility.eligible, job: job);
  }

  Future<String?> findApplicationIdForJob(String jobPostId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      return _mockApplicationIdForJob(jobPostId);
    }
    try {
      final applications = await _applicationService.listApplications(
          jobPostId: jobPostId, limit: 1);
      if (applications.isEmpty) return null;
      return applications.first.applicationId;
    } on JobApplicationServiceException {
      return null;
    }
  }

  Future<ApplyCvResult> submitApplication({
    required String jobPostId,
    required String cvFileId,
    String? applicationNote,
    String? jobTitle,
    String? organization,
    String? cvFileName,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      await _ensureMockSeed();
      _mockAppliedJobs.add(jobPostId);
      final applicationId = 'app-${DateTime.now().millisecondsSinceEpoch}';
      final now = DateTime.now();
      _mockApplicationDetails[applicationId] = ApplicationDetailModel(
        applicationId: applicationId,
        jobPostId: jobPostId,
        jobTitle: jobTitle ?? 'Job Position',
        organization: organization,
        status: ApplicationStatus.pending,
        appliedAt: now,
        cvFileName: cvFileName,
        applicantUserId: MockIds.currentUser,
      );
      _mockSubmittedApplicationIds.add(applicationId);
      await _persistAppliedJobs();
      await _persistSubmittedApplications();
      return ApplyCvResult(
        jobPostId: jobPostId,
        applicationId: applicationId,
      );
    }

    try {
      final response = await _applicationService.createApplication(
        jobPostId: jobPostId,
        cvFileId: cvFileId,
        applicationNote: applicationNote,
      );
      return ApplyCvResult(
        jobPostId: response.jobPostId,
        applicationId: response.applicationId,
      );
    } on JobApplicationServiceException catch (error) {
      if (error.isConflict) {
        final existing = await _applicationService.listApplications(
            jobPostId: jobPostId, limit: 1);
        if (existing.isNotEmpty) {
          return ApplyCvResult(
            jobPostId: jobPostId,
            applicationId: existing.first.applicationId,
          );
        }
      }
      rethrow;
    }
  }

  Future<ApplicationDetailModel> getApplicationDetail(
      String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockSeed();
      final cached = _mockApplicationDetails[applicationId];
      if (cached != null) return cached;
      return ApplicationDetailModel(
        applicationId: applicationId,
        jobPostId: 'unknown',
        jobTitle: 'Web Developer',
        organization: 'Aeon Mall',
        status: ApplicationStatus.pending,
        appliedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    final response = await _applicationService.getApplication(applicationId);
    final job = await _postRepository.fetchPost(response.jobPostId);
    return _mapToDetail(response, job: job);
  }

  Future<List<JobApplicationModel>> getApplicantsForJob(
      String jobPostId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      return List<JobApplicationModel>.from(
        ApplicationFixtures.buildApplicantsByJob()[jobPostId] ??
            ApplicationFixtures.defaultApplicants(),
      );
    }
    final applications =
        await _applicationService.listApplications(jobPostId: jobPostId);
    return applications.asMap().entries.map((entry) {
      final index = entry.key;
      final app = entry.value;
      return JobApplicationModel(
        id: app.applicationId,
        jobPostId: app.jobPostId,
        applicantName: app.applicantName ?? 'Applicant',
        applicantUserId: app.applicantUserId,
        headline: app.applicantHeadline,
        location: app.applicantLocation,
        email: app.applicantEmail,
        appliedAt: app.appliedAt ?? DateTime.now(),
        status: app.mappedStatus,
        cvFileName: app.cvFileName,
        rank: index + 1,
      );
    }).toList();
  }

  Future<List<AppliedJobSummary>> getMyAppliedJobs() async {
    if (useMockApi) {
      await _ensureMockSeed();
      final byId = <String, AppliedJobSummary>{
        for (final summary in ApplicationFixtures.myAppliedJobs())
          summary.id: summary,
      };
      for (final jobPostId in _mockAppliedJobs) {
        final applicationId = _mockApplicationIdForJob(jobPostId);
        if (applicationId == null || byId.containsKey(applicationId)) continue;
        final detail = _mockApplicationDetails[applicationId];
        if (detail == null) continue;
        final job = await _postRepository.fetchPost(jobPostId);
        byId[applicationId] = AppliedJobSummary(
          id: applicationId,
          jobPostId: jobPostId,
          jobTitle: detail.jobTitle,
          company: detail.organization ??
              job?.jobMeta.description ??
              job?.author.fullName ??
              '',
          employmentType: job?.jobMeta.requirement,
          location: job?.content.isNotEmpty == true
              ? job!.content.split('\n').first
              : null,
          mediaUrl: job?.mediaUrl,
          status: detail.status,
          appliedAt: detail.appliedAt,
        );
      }
      final summaries = byId.values.toList()
        ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
      return summaries;
    }
    final applications = await _applicationService.listApplications();
    final summaries = <AppliedJobSummary>[];
    for (final app in applications) {
      final job = await _postRepository.fetchPost(app.jobPostId);
      summaries.add(
        AppliedJobSummary(
          id: app.applicationId,
          jobPostId: app.jobPostId,
          jobTitle: app.jobTitle ?? job?.jobMeta.title ?? job?.content ?? 'Job',
          company: app.organization ?? job?.author.fullName ?? '',
          employmentType: job?.jobMeta.requirement,
          location: job?.content.isNotEmpty == true ? job!.content.split('\n').first : null,
          mediaUrl: job?.mediaUrl,
          status: app.mappedStatus,
          appliedAt: app.appliedAt ?? DateTime.now(),
        ),
      );
    }
    return summaries;
  }

  Future<void> updateApplicationStatus(
      String applicationId, ApplicationStatus status) async {
    if (useMockApi) {
      await setMockApplicationStatus(applicationId, status);
      return;
    }
    await _applicationService.updateApplicationStatus(
      applicationId: applicationId,
      status: status,
    );
  }

  Future<Set<String>> getAppliedJobPostIds() async {
    if (useMockApi) {
      await _ensureMockSeed();
      return Set<String>.from(_mockAppliedJobs);
    }
    final applications = await _applicationService.listApplications();
    return applications.map((app) => app.jobPostId).toSet();
  }

  Future<bool> hasUserApplied(String jobPostId) async {
    if (useMockApi) {
      await _ensureMockSeed();
      return _mockAppliedJobs.contains(jobPostId);
    }
    return _applicationService.hasApplied(jobPostId);
  }

  String? _mockApplicationIdForJob(String jobPostId) {
    // Prefer the logged-in user's application when several people applied.
    for (final entry in _mockApplicationDetails.entries) {
      final detail = entry.value;
      if (detail.jobPostId != jobPostId) continue;
      if (detail.applicantUserId == null ||
          detail.applicantUserId == MockIds.currentUser) {
        return entry.key;
      }
    }
    for (final entry in _mockApplicationDetails.entries) {
      if (entry.value.jobPostId == jobPostId) return entry.key;
    }
    return null;
  }

  ApplicationDetailModel _mapToDetail(JobApplicationResponse response,
      {FeedPost? job}) {
    final status = response.mappedStatus;
    return ApplicationDetailModel(
      applicationId: response.applicationId,
      jobPostId: response.jobPostId,
      jobTitle:
          response.jobTitle ?? job?.jobMeta.title ?? job?.content ?? 'Job',
      organization: response.organization ?? job?.author.fullName,
      status: status,
      appliedAt: response.appliedAt ?? DateTime.now(),
      reviewStartedAt: response.reviewStartedAt ??
          (status == ApplicationStatus.reviewed ? response.appliedAt : null),
      decidedAt: response.decidedAt ??
          (status == ApplicationStatus.accepted ||
                  status == ApplicationStatus.rejected
              ? response.appliedAt
              : null),
      reviewerNote: response.reviewerNote,
      cvFileName: response.cvFileName,
      applicantUserId: response.applicantUserId,
      applicantName: response.applicantName,
      applicantHeadline: response.applicantHeadline,
      applicantLocation: response.applicantLocation,
      applicantEmail: response.applicantEmail,
    );
  }

  /// Demo helper — cycles mock status for testing UI variants.
  Future<void> setMockApplicationStatus(
      String applicationId, ApplicationStatus status) async {
    await _ensureMockSeed();
    _applyStatusInMemory(applicationId, status);
    await _persistApplicationStatus(applicationId, status);
    if (_mockSubmittedApplicationIds.contains(applicationId)) {
      await _persistSubmittedApplications();
    }
  }
}
