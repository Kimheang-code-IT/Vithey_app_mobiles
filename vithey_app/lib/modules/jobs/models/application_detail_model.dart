import 'package:aub_connect_app/data/models/user_profile_model.dart';

enum ApplicationPhase { submitted, underPreview, decision }

class ApplicationTimelineStep {
  const ApplicationTimelineStep({
    required this.phase,
    required this.label,
    this.completedAt,
    this.statusText,
    required this.isComplete,
    required this.isCurrent,
    this.isRejectedDecision = false,
    this.isAcceptedDecision = false,
  });

  final ApplicationPhase phase;
  final String label;
  final DateTime? completedAt;
  final String? statusText;
  final bool isComplete;
  final bool isCurrent;
  final bool isRejectedDecision;
  final bool isAcceptedDecision;
}

class ApplicationDetailModel {
  const ApplicationDetailModel({
    required this.applicationId,
    required this.jobPostId,
    required this.jobTitle,
    this.organization,
    required this.status,
    required this.appliedAt,
    this.reviewStartedAt,
    this.decidedAt,
    this.reviewerNote,
    this.cvFileName,
    this.applicantUserId,
    this.applicantName,
    this.applicantHeadline,
    this.applicantLocation,
    this.applicantEmail,
  });

  final String applicationId;
  final String jobPostId;
  final String jobTitle;
  final String? organization;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? reviewStartedAt;
  final DateTime? decidedAt;
  final String? reviewerNote;
  final String? cvFileName;
  final String? applicantUserId;
  final String? applicantName;
  final String? applicantHeadline;
  final String? applicantLocation;
  final String? applicantEmail;

  List<ApplicationTimelineStep> buildTimeline() {
    final submittedComplete = true;
    final reviewComplete = status != ApplicationStatus.pending;
    final decisionComplete = status == ApplicationStatus.accepted || status == ApplicationStatus.rejected;

    return [
      ApplicationTimelineStep(
        phase: ApplicationPhase.submitted,
        label: 'Submitted',
        completedAt: appliedAt,
        isComplete: submittedComplete,
        isCurrent: status == ApplicationStatus.pending && reviewStartedAt == null,
      ),
      ApplicationTimelineStep(
        phase: ApplicationPhase.underPreview,
        label: 'Under Preview',
        completedAt: reviewStartedAt,
        statusText: reviewComplete ? null : 'Pending',
        isComplete: reviewComplete,
        isCurrent: status == ApplicationStatus.reviewed ||
            (status == ApplicationStatus.pending && reviewStartedAt != null),
      ),
      ApplicationTimelineStep(
        phase: ApplicationPhase.decision,
        label: 'Decision',
        completedAt: decidedAt,
        statusText: decisionComplete ? null : 'Pending',
        isComplete: decisionComplete,
        isCurrent: status == ApplicationStatus.accepted || status == ApplicationStatus.rejected,
        isRejectedDecision: status == ApplicationStatus.rejected,
        isAcceptedDecision: status == ApplicationStatus.accepted,
      ),
    ];
  }

  String get heroTitle {
    switch (status) {
      case ApplicationStatus.pending:
        return reviewStartedAt == null ? 'Application Submitted!' : 'Under Review';
      case ApplicationStatus.reviewed:
        return 'Under Review';
      case ApplicationStatus.accepted:
        return 'Accepted';
      case ApplicationStatus.rejected:
        return 'Not Selected';
    }
  }

  String get heroSubtitle {
    switch (status) {
      case ApplicationStatus.pending:
        return reviewStartedAt == null
            ? 'Your application has been submitted successfully.'
            : 'Your application is currently under review.';
      case ApplicationStatus.reviewed:
        return 'Your application is currently under review.';
      case ApplicationStatus.accepted:
        return 'Congratulations! Your application has been accepted.';
      case ApplicationStatus.rejected:
        return "Thank you for your interest. Unfortunately, your application wasn't selected for this position.";
    }
  }

  String get bannerMessage {
    switch (status) {
      case ApplicationStatus.pending:
        return reviewStartedAt == null
            ? "We'll notify you by this app when there's an update."
            : 'Thanks for your patience while the review is processing.';
      case ApplicationStatus.reviewed:
        return 'Thanks for your patience while the review is processing.';
      case ApplicationStatus.accepted:
      case ApplicationStatus.rejected:
        return '';
    }
  }
}
