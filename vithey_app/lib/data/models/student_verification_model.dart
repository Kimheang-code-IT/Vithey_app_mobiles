enum VerificationStatus { notSubmitted, pending, verified, rejected }

enum FinanceProvisioningStatus { unknown, provisioning, ready, failed }

class StudentVerificationModel {
  const StudentVerificationModel({
    required this.status,
    this.id,
    this.studentId,
    this.universityEmail,
    this.submittedAt,
    this.verifiedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.canResubmit = true,
    this.documentFileName,
  });

  final String? id;
  final VerificationStatus status;
  final String? studentId;
  final String? universityEmail;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final DateTime? rejectedAt;
  final String? rejectionReason;
  final bool canResubmit;
  final String? documentFileName;

  bool get isVerified => status == VerificationStatus.verified;

  StudentVerificationModel copyWith({
    VerificationStatus? status,
    DateTime? verifiedAt,
    String? rejectionReason,
    bool? canResubmit,
  }) {
    return StudentVerificationModel(
      id: id,
      status: status ?? this.status,
      studentId: studentId,
      universityEmail: universityEmail,
      submittedAt: submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      rejectedAt: rejectedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      canResubmit: canResubmit ?? this.canResubmit,
      documentFileName: documentFileName,
    );
  }
}

class VerificationTimelineStage {
  const VerificationTimelineStage({
    required this.title,
    required this.subtitle,
    required this.isCompleted,
    required this.isActive,
  });

  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool isActive;
}
