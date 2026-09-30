import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/fixtures/application_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/cv_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/applicant_detail_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';
import 'package:aub_connect_app/data/repositories/cv_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/data/services/profile_service.dart';

class ProfileRepository {
  ProfileRepository(
    this._profileService,
    this._postRepository,
    this._jobApplicationRepository,
    this._cvRepository,
    this._currentUser,
    this._flags,
    this._localStorage,
  );

  final ProfileService _profileService;
  final PostRepository _postRepository;
  final JobApplicationRepository _jobApplicationRepository;
  final CvRepository _cvRepository;
  final CurrentUserService _currentUser;
  final FeatureFlags _flags;
  final LocalStorageService _localStorage;

  static String get currentUserId {
    if (Get.isRegistered<CurrentUserService>()) {
      return Get.find<CurrentUserService>().userId;
    }
    return MockIdentities.mockUserId;
  }

  bool get useMockApi => _flags.useMockApi;
  static Future<void>? _mockApplicantStatusesFuture;

  Future<UserProfileModel> getProfile(String userId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      return _withFollowState(
        _mockProfiles[userId] ?? _mockProfiles[_currentUser.userId]!,
      );
    }
    if (userId == currentUserId) {
      return _profileService.getMyProfile();
    }
    return _profileService.getUserProfile(userId);
  }

  Future<List<FeedPost>> getUserPosts({
    required String userId,
    required PostType type,
    required int page,
  }) async {
    final result = await _postRepository.fetchUserPosts(userId: userId, type: type, page: page);
    return result.posts;
  }

  Future<void> toggleFollow(String userId) => _postRepository.setFollow(userId, !_postRepository.isFollowing(userId));

  bool isFollowing(String userId) => _postRepository.isFollowing(userId);

  Future<CvMetadataModel?> getOwnCv() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return CvFixtures.savedCv();
    }
    return _cvRepository.getSavedCv();
  }

  Future<List<JobApplicationModel>> getJobApplicants(String jobPostId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockApplicantStatuses();
      return _mockApplicants[jobPostId] ?? _defaultApplicants;
    }
    return _jobApplicationRepository.getApplicantsForJob(jobPostId);
  }

  Future<List<AppliedJobSummary>> getMyAppliedJobs() async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
    }
    return _jobApplicationRepository.getMyAppliedJobs();
  }

  Future<List<AppliedJobSummary>> getUserAppliedJobs(String userId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return ApplicationFixtures.appliedJobsFor(userId);
    }
    if (userId == currentUserId) {
      return getMyAppliedJobs();
    }
    return const [];
  }

  Future<UserProfileModel> updateProfile({
    String? fullName,
    String? bio,
    String? location,
    String? gender,
    String? workplace,
    String? portfolioUrl,
    String? telegramLink,
    String? facebookLink,
    String? avatarUrl,
    String? phone,
    String? email,
    String? university,
    String? major,
    int? graduationYear,
    DateTime? dateOfBirth,
    bool updateDateOfBirth = false,
    List<String>? education,
    List<String>? workplaces,
    List<String>? personalExtras,
    List<String>? otherLinks,
    List<String>? otherContacts,
    List<ProfileSkill>? skills,
    List<ProfileWorkEntry>? workEntries,
    List<ProfileEducationEntry>? educationEntries,
    List<ProfileLinkEntry>? linkEntries,
    List<ProfileContactEntry>? contactEntries,
  }) async {
    String? clearable(String? incoming) {
      if (incoming == null) return null;
      final t = incoming.trim();
      return t.isEmpty ? null : t;
    }

    final clearedBio = clearable(bio);
    final clearedLocation = clearable(location);
    final clearedGender = clearable(gender);
    final clearedWorkplace = clearable(workplace);
    final clearedPortfolio = clearable(portfolioUrl);
    final clearedTelegram = clearable(telegramLink);
    final clearedFacebook = clearable(facebookLink);
    final clearedPhone = clearable(phone);
    final clearedEmail = clearable(email);
    final clearedUniversity = clearable(university);
    final clearedMajor = clearable(major);

    final fields = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (bio != null) 'bio': clearedBio ?? '',
      if (location != null) 'location': clearedLocation,
      if (gender != null) 'gender': clearedGender,
      if (workplace != null) 'workplace': clearedWorkplace,
      if (portfolioUrl != null) 'portfolio_url': clearedPortfolio,
      if (telegramLink != null) 'telegram_link': clearedTelegram,
      if (facebookLink != null) 'facebook_link': clearedFacebook,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (phone != null) 'phone': clearedPhone,
      if (email != null) 'email': clearedEmail,
      if (university != null) 'university': clearedUniversity,
      if (major != null) 'major': clearedMajor,
      if (graduationYear != null) 'graduation_year': graduationYear,
      if (skills != null)
        'skills': skills.map((s) => s.toJson()).toList(),
    };
    final hasListUpdate = education != null ||
        workplaces != null ||
        personalExtras != null ||
        otherLinks != null ||
        otherContacts != null ||
        skills != null ||
        workEntries != null ||
        educationEntries != null ||
        linkEntries != null ||
        contactEntries != null ||
        updateDateOfBirth;
    if (fields.isEmpty && !hasListUpdate) {
      return getProfile(currentUserId);
    }
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      final current = _mockProfiles[currentUserId]!;
      final works = workEntries ?? current.workItems;
      final edus = educationEntries ?? current.educationItems;
      final links = linkEntries ?? current.linkItems;
      final contacts = contactEntries ?? current.contactItems;
      final updated = UserProfileModel(
        id: current.id,
        fullName: fullName ?? current.fullName,
        bio: bio != null ? clearedBio : current.bio,
        avatarUrl: avatarUrl ?? current.avatarUrl,
        coverUrl: current.coverUrl,
        university: university != null ? clearedUniversity : current.university,
        major: major != null ? clearedMajor : current.major,
        graduationYear: graduationYear ?? current.graduationYear,
        telegramLink:
            telegramLink != null ? clearedTelegram : current.telegramLink,
        facebookLink:
            facebookLink != null ? clearedFacebook : current.facebookLink,
        followerCount: current.followerCount,
        followingCount: current.followingCount,
        postCount: current.postCount,
        likeCount: current.likeCount,
        isFollowing: current.isFollowing,
        skills: skills ?? current.skills,
        location: location != null ? clearedLocation : current.location,
        gender: gender != null ? clearedGender : current.gender,
        dateOfBirth: updateDateOfBirth ? dateOfBirth : current.dateOfBirth,
        workplace: works.isNotEmpty
            ? works.first.workplace
            : (workplace != null ? clearedWorkplace : current.workplace),
        workplaces: works.map((w) => w.workplace).toList(),
        workEntries: works,
        education: edus.map((e) => e.school).toList(),
        educationEntries: edus,
        personalExtras: personalExtras ?? current.personalExtras,
        otherLinks: otherLinks ?? current.otherLinks,
        linkEntries: links,
        otherContacts: otherContacts ?? current.otherContacts,
        contactEntries: contacts,
        portfolioUrl:
            portfolioUrl != null ? clearedPortfolio : current.portfolioUrl,
        phone: phone != null
            ? clearedPhone
            : (contacts.isNotEmpty ? contacts.first.phone : current.phone),
        email: email != null
            ? clearedEmail
            : (contacts.isNotEmpty ? contacts.first.email : current.email),
        isStudentVerified: current.isStudentVerified,
      );
      _mockProfiles[currentUserId] = updated;
      return updated;
    }
    return _profileService.updateMyProfile(fields);
  }

  Future<String?> getApplicantCvPreviewUrl(String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return CvFixtures.previewUrl;
    }
    try {
      final application = await _jobApplicationRepository.getApplicationDetail(applicationId);
      if (application.cvFileName == null) return null;
      return _cvRepository.getApplicantCvDownloadUrl(applicationId);
    } catch (_) {
      return null;
    }
  }

  Future<ApplicantDetailModel> getApplicantDetail(String applicationId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockApplicantStatuses();
      return _buildMockApplicantDetail(applicationId);
    }

    final application = await _jobApplicationRepository.getApplicationDetail(applicationId);
    UserProfileModel? profile;
    final applicantId = application.applicantUserId;
    if (applicantId != null && applicantId.isNotEmpty) {
      try {
        profile = await getProfile(applicantId);
      } catch (_) {}
    }

    return ApplicantDetailModel(
      applicationId: application.applicationId,
      jobPostId: application.jobPostId,
      jobTitle: application.jobTitle,
      applicantUserId: applicantId ?? '',
      applicantName: application.applicantName ?? profile?.fullName ?? 'Applicant',
      headline: application.applicantHeadline ?? profile?.workplace,
      location: application.applicantLocation ?? profile?.location,
      email: application.applicantEmail ?? profile?.email,
      avatarUrl: profile?.avatarUrl,
      status: application.status,
      cvFileName: application.cvFileName,
      experience: _experienceFromProfile(profile),
      education: _educationFromProfile(profile),
    );
  }

  ApplicantDetailModel _buildMockApplicantDetail(String applicationId) {
    final application = _findMockApplication(applicationId);
    final details = ApplicationFixtures.buildApplicationDetails()[applicationId];
    final userId = application.applicantUserId ?? details?.applicantUserId ?? 'author-1';
    final profile = _mockProfiles[userId];

    return ApplicantDetailModel(
      applicationId: application.id,
      jobPostId: application.jobPostId,
      jobTitle: details?.jobTitle ?? application.headline ?? 'Job',
      applicantUserId: userId,
      applicantName: details?.applicantName ?? application.applicantName,
      headline: details?.applicantHeadline ?? application.headline,
      location: details?.applicantLocation ?? application.location ?? profile?.location,
      email: details?.applicantEmail ?? application.email ?? profile?.email,
      avatarUrl: profile?.avatarUrl,
      status: application.status,
      // Original uploaded file name from the application record.
      cvFileName: details?.cvFileName ?? application.cvFileName,
      experience: _mockExperienceFor(userId),
      education: _mockEducationFor(userId),
    );
  }

  JobApplicationModel _findMockApplication(String applicationId) {
    for (final list in _mockApplicants.values) {
      final match = list.where((a) => a.id == applicationId);
      if (match.isNotEmpty) return match.first;
    }
    return _defaultApplicants.firstWhere(
      (a) => a.id == applicationId,
      orElse: () => _defaultApplicants.first,
    );
  }

  List<ApplicantExperienceEntry> _mockExperienceFor(String userId) =>
      ApplicationFixtures.experienceFor(userId);

  List<ApplicantEducationEntry> _mockEducationFor(String userId) =>
      ApplicationFixtures.educationFor(userId);

  List<ApplicantExperienceEntry> _experienceFromProfile(UserProfileModel? profile) {
    if (profile?.workplace == null) return const [];
    return [
      ApplicantExperienceEntry(
        title: profile!.major ?? 'Professional',
        organization: profile.workplace!,
        period: 'Present',
        description: profile.bio,
      ),
    ];
  }

  List<ApplicantEducationEntry> _educationFromProfile(UserProfileModel? profile) {
    if (profile == null) return const [];
    final school = profile.university;
    if (school == null) return const [];
    return [
      ApplicantEducationEntry(
        degree: profile.major ?? 'Student',
        school: school,
        period: profile.graduationYear?.toString() ?? 'Present',
      ),
    ];
  }

  static final _mockProfiles = Map<String, UserProfileModel>.from(UserFixtures.buildProfiles());

  static final _defaultApplicants = List<JobApplicationModel>.from(ApplicationFixtures.defaultApplicants());

  static final _mockApplicants = Map<String, List<JobApplicationModel>>.from(
    ApplicationFixtures.buildApplicantsByJob(),
  );

  Future<void> updateApplicationStatus(String applicationId, ApplicationStatus status) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockApplicantStatuses();
      var updated = false;
      for (final list in _mockApplicants.values) {
        final index = list.indexWhere((a) => a.id == applicationId);
        if (index >= 0) {
          list[index] = list[index].copyWith(status: status);
          updated = true;
          break;
        }
      }
      if (!updated) {
        for (var i = 0; i < _defaultApplicants.length; i++) {
          if (_defaultApplicants[i].id == applicationId) {
            _defaultApplicants[i] = _defaultApplicants[i].copyWith(status: status);
            updated = true;
            break;
          }
        }
      }
      if (updated) {
        final statuses = await _localStorage.readMockApplicationStatuses();
        statuses[applicationId] = status.name;
        await _localStorage.saveMockApplicationStatuses(statuses);
        await _jobApplicationRepository.setMockApplicationStatus(
          applicationId,
          status,
        );
      }
      return;
    }
    await _jobApplicationRepository.updateApplicationStatus(applicationId, status);
  }

  Future<void> _ensureMockApplicantStatuses() async {
    if (!useMockApi) return;
    _mockApplicantStatusesFuture ??= _loadMockApplicantStatuses();
    await _mockApplicantStatusesFuture;
  }

  Future<void> _loadMockApplicantStatuses() async {
    final statuses = await _localStorage.readMockApplicationStatuses();
    for (final entry in statuses.entries) {
      ApplicationStatus? status;
      for (final value in ApplicationStatus.values) {
        if (value.name == entry.value) {
          status = value;
          break;
        }
      }
      if (status == null) continue;
      for (final list in _mockApplicants.values) {
        final index = list.indexWhere((a) => a.id == entry.key);
        if (index >= 0) {
          list[index] = list[index].copyWith(status: status);
        }
      }
      for (var i = 0; i < _defaultApplicants.length; i++) {
        if (_defaultApplicants[i].id == entry.key) {
          _defaultApplicants[i] =
              _defaultApplicants[i].copyWith(status: status);
        }
      }
    }
  }

  UserProfileModel _withFollowState(UserProfileModel profile) {
    return profile.copyWith(isFollowing: _postRepository.isFollowing(profile.id));
  }
}
