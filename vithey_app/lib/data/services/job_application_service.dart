import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

class JobApplicationResponse {
  const JobApplicationResponse({
    required this.applicationId,
    required this.jobPostId,
    required this.cvFileId,
    required this.status,
    this.jobTitle,
    this.organization,
    this.cvFileName,
    this.coverNote,
    this.appliedAt,
    this.reviewStartedAt,
    this.decidedAt,
    this.reviewerNote,
    this.applicantName,
    this.applicantUserId,
    this.applicantHeadline,
    this.applicantLocation,
    this.applicantEmail,
  });

  final String applicationId;
  final String jobPostId;
  final String cvFileId;
  final String status;
  final String? jobTitle;
  final String? organization;
  final String? cvFileName;
  final String? coverNote;
  final DateTime? appliedAt;
  final DateTime? reviewStartedAt;
  final DateTime? decidedAt;
  final String? reviewerNote;
  final String? applicantName;
  final String? applicantUserId;
  final String? applicantHeadline;
  final String? applicantLocation;
  final String? applicantEmail;

  static JobApplicationResponse fromJson(Map<String, dynamic> data) {
    final applicant = data['applicant'] as Map<String, dynamic>?;
    return JobApplicationResponse(
      applicationId: data['application_id']?.toString() ?? data['id']?.toString() ?? '',
      jobPostId: data['job_post_id']?.toString() ?? '',
      cvFileId: data['cv_file_id']?.toString() ?? '',
      status: data['status']?.toString() ?? 'PENDING',
      jobTitle: data['job_title'] as String?,
      organization: data['organization'] as String?,
      cvFileName: data['cv_file_name'] as String?,
      coverNote: data['cover_note'] as String? ?? data['application_note'] as String?,
      appliedAt: _parseDateTime(data['applied_at']),
      reviewStartedAt: _parseDateTime(data['review_started_at']),
      decidedAt: _parseDateTime(data['decided_at']),
      reviewerNote: data['reviewer_note'] as String?,
      applicantName: applicant?['full_name'] as String? ?? applicant?['name'] as String?,
      applicantUserId: applicant?['user_id']?.toString() ?? applicant?['id']?.toString(),
      applicantHeadline: applicant?['headline'] as String?,
      applicantLocation: applicant?['location'] as String?,
      applicantEmail: applicant?['email'] as String?,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }

  ApplicationStatus get mappedStatus => mapApplicationStatus(status);
}

ApplicationStatus mapApplicationStatus(String raw) {
  switch (raw.toUpperCase()) {
    case 'REVIEWED':
      return ApplicationStatus.reviewed;
    case 'ACCEPTED':
      return ApplicationStatus.accepted;
    case 'REJECTED':
      return ApplicationStatus.rejected;
    default:
      return ApplicationStatus.pending;
  }
}

String applicationStatusToApi(ApplicationStatus status) {
  return switch (status) {
    ApplicationStatus.reviewed => 'REVIEWED',
    ApplicationStatus.accepted => 'ACCEPTED',
    ApplicationStatus.rejected => 'REJECTED',
    ApplicationStatus.pending => 'PENDING',
  };
}

class JobApplicationService {
  JobApplicationService(this._api);

  final ApiService _api;

  Future<JobApplicationResponse> createApplication({
    required String jobPostId,
    required String cvFileId,
    String? applicationNote,
  }) async {
    final response = await _api.post<JobApplicationResponse>(
      ApiEndpoints.jobApplications(),
      data: {
        'job_post_id': jobPostId,
        'cv_file_id': cvFileId,
        if (applicationNote != null && applicationNote.isNotEmpty) 'application_note': applicationNote,
      },
      fromJson: (json) => JobApplicationResponse.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw JobApplicationServiceException(
        response.error?.message ?? 'Application failed',
        code: response.error?.code,
      );
    }
    return response.data!;
  }

  Future<JobApplicationResponse> getApplication(String applicationId) async {
    final response = await _api.get<JobApplicationResponse>(
      ApiEndpoints.jobApplicationById(applicationId),
      fromJson: (json) => JobApplicationResponse.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw JobApplicationServiceException(
        response.error?.message ?? 'Could not load application',
        code: response.error?.code,
      );
    }
    return response.data!;
  }

  Future<List<JobApplicationResponse>> listApplications({
    String? jobPostId,
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _api.get<List<JobApplicationResponse>>(
      ApiEndpoints.jobApplications(),
      queryParameters: {
        if (jobPostId != null) 'job_post_id': jobPostId,
        'page': page,
        'limit': limit,
      },
      fromJson: _parseApplicationList,
    );
    if (!response.isSuccess || response.data == null) {
      throw JobApplicationServiceException(
        response.error?.message ?? 'Could not load applications',
        code: response.error?.code,
      );
    }
    return response.data!;
  }

  Future<bool> hasApplied(String jobPostId) async {
    try {
      final applications = await listApplications(jobPostId: jobPostId, limit: 1);
      return applications.isNotEmpty;
    } on JobApplicationServiceException {
      return false;
    }
  }

  Future<JobApplicationResponse> updateApplicationStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    final response = await _api.patch<JobApplicationResponse>(
      ApiEndpoints.jobApplicationStatus(applicationId),
      data: {'status': applicationStatusToApi(status)},
      fromJson: (json) => JobApplicationResponse.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw JobApplicationServiceException(
        response.error?.message ?? 'Could not update application status',
        code: response.error?.code,
      );
    }
    return response.data!;
  }

  List<JobApplicationResponse> _parseApplicationList(dynamic json) {
    if (json is List) {
      return json
          .whereType<Map<String, dynamic>>()
          .map(JobApplicationResponse.fromJson)
          .toList();
    }
    if (json is Map<String, dynamic>) {
      final items = json['items'] ?? json['content'];
      if (items is List) {
        return items
            .whereType<Map<String, dynamic>>()
            .map(JobApplicationResponse.fromJson)
            .toList();
      }
    }
    return [];
  }
}

class JobApplicationServiceException implements Exception {
  JobApplicationServiceException(this.message, {this.code});

  final String message;
  final String? code;

  bool get isConflict => code == 'CONFLICT';

  @override
  String toString() => message;
}
