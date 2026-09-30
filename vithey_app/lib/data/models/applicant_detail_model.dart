import 'package:aub_connect_app/data/models/user_profile_model.dart';

class ApplicantExperienceEntry {
  const ApplicantExperienceEntry({
    required this.title,
    required this.organization,
    required this.period,
    this.description,
  });

  final String title;
  final String organization;
  final String period;
  final String? description;
}

class ApplicantEducationEntry {
  const ApplicantEducationEntry({
    required this.degree,
    required this.school,
    required this.period,
  });

  final String degree;
  final String school;
  final String period;
}

class ApplicantDetailModel {
  const ApplicantDetailModel({
    required this.applicationId,
    required this.jobPostId,
    required this.jobTitle,
    required this.applicantUserId,
    required this.applicantName,
    this.headline,
    this.location,
    this.email,
    this.avatarUrl,
    required this.status,
    this.cvFileName,
    this.experience = const [],
    this.education = const [],
  });

  final String applicationId;
  final String jobPostId;
  final String jobTitle;
  final String applicantUserId;
  final String applicantName;
  final String? headline;
  final String? location;
  final String? email;
  final String? avatarUrl;
  final ApplicationStatus status;
  final String? cvFileName;
  final List<ApplicantExperienceEntry> experience;
  final List<ApplicantEducationEntry> education;

  bool get hasCv => cvFileName != null && cvFileName!.isNotEmpty;
}
