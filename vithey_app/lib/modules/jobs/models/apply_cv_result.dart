enum ApplyCvStatus { pending, reviewed, accepted, rejected }

class ApplyCvResult {
  const ApplyCvResult({
    required this.jobPostId,
    required this.applicationId,
    this.status = ApplyCvStatus.pending,
  });

  final String jobPostId;
  final String applicationId;
  final ApplyCvStatus status;
}
