class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.university,
    this.major,
    this.graduationYear,
    this.telegramLink,
    this.facebookLink,
    this.followerCount = 0,
    this.followingCount = 0,
    this.postCount = 0,
    this.likeCount = 0,
    this.isFollowing = false,
    this.skills = const [],
    this.location,
    this.gender,
    this.dateOfBirth,
    this.workplace,
    this.workplaces = const [],
    this.workEntries = const [],
    this.education = const [],
    this.educationEntries = const [],
    this.personalExtras = const [],
    this.otherLinks = const [],
    this.linkEntries = const [],
    this.otherContacts = const [],
    this.contactEntries = const [],
    this.portfolioUrl,
    this.phone,
    this.email,
    this.isStudentVerified = false,
  });

  final String id;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final String? university;
  final String? major;
  final int? graduationYear;
  final String? telegramLink;
  final String? facebookLink;
  final int followerCount;
  final int followingCount;
  final int postCount;
  final int likeCount;
  final bool isFollowing;
  final List<ProfileSkill> skills;
  final String? location;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? workplace;
  final List<String> workplaces;
  final List<ProfileWorkEntry> workEntries;
  final List<String> education;
  final List<ProfileEducationEntry> educationEntries;
  final List<String> personalExtras;
  final List<String> otherLinks;
  final List<ProfileLinkEntry> linkEntries;
  final List<String> otherContacts;
  final List<ProfileContactEntry> contactEntries;
  final String? portfolioUrl;
  final String? phone;
  final String? email;
  final bool isStudentVerified;

  /// Structured work first; fall back to legacy workplace strings.
  List<ProfileWorkEntry> get workItems {
    if (workEntries.isNotEmpty) return workEntries;
    final places = workplaces.isNotEmpty
        ? workplaces
        : (workplace != null && workplace!.trim().isNotEmpty
            ? [workplace!]
            : <String>[]);
    return [
      for (final place in places)
        ProfileWorkEntry(position: '', workplace: place),
    ];
  }

  List<ProfileEducationEntry> get educationItems {
    if (educationEntries.isNotEmpty) return educationEntries;
    return [
      for (final school in education)
        if (school.trim().isNotEmpty)
          ProfileEducationEntry(school: school),
      if (university != null &&
          university!.trim().isNotEmpty &&
          !education.contains(university))
        ProfileEducationEntry(
          school: university!,
          major: major,
        ),
    ];
  }

  List<ProfileLinkEntry> get linkItems {
    if (linkEntries.isNotEmpty) return linkEntries;
    return [
      if (portfolioUrl != null && portfolioUrl!.trim().isNotEmpty)
        ProfileLinkEntry(platform: 'Website', url: portfolioUrl!),
      if (telegramLink != null && telegramLink!.trim().isNotEmpty)
        ProfileLinkEntry(platform: 'Telegram', url: telegramLink!),
      if (facebookLink != null && facebookLink!.trim().isNotEmpty)
        ProfileLinkEntry(platform: 'Facebook', url: facebookLink!),
      for (final link in otherLinks)
        if (link.trim().isNotEmpty)
          ProfileLinkEntry(platform: 'Link', url: link),
    ];
  }

  List<ProfileContactEntry> get contactItems {
    if (contactEntries.isNotEmpty) return contactEntries;
    final hasPhone = phone != null && phone!.trim().isNotEmpty;
    final hasEmail = email != null && email!.trim().isNotEmpty;
    if (!hasPhone && !hasEmail && otherContacts.isEmpty) return const [];
    return [
      if (hasPhone || hasEmail)
        ProfileContactEntry(phone: phone, email: email),
      for (final c in otherContacts)
        if (c.trim().isNotEmpty) ProfileContactEntry(phone: c),
    ];
  }

  UserProfileModel copyWith({
    String? fullName,
    String? bio,
    String? avatarUrl,
    String? coverUrl,
    String? university,
    String? major,
    int? graduationYear,
    String? telegramLink,
    String? facebookLink,
    int? followerCount,
    int? followingCount,
    int? likeCount,
    bool? isFollowing,
    List<ProfileSkill>? skills,
    String? location,
    String? gender,
    DateTime? dateOfBirth,
    String? workplace,
    List<String>? workplaces,
    List<ProfileWorkEntry>? workEntries,
    List<String>? education,
    List<ProfileEducationEntry>? educationEntries,
    List<String>? personalExtras,
    List<String>? otherLinks,
    List<ProfileLinkEntry>? linkEntries,
    List<String>? otherContacts,
    List<ProfileContactEntry>? contactEntries,
    String? portfolioUrl,
    String? phone,
    String? email,
    bool? isStudentVerified,
  }) {
    return UserProfileModel(
      id: id,
      fullName: fullName ?? this.fullName,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      university: university ?? this.university,
      major: major ?? this.major,
      graduationYear: graduationYear ?? this.graduationYear,
      telegramLink: telegramLink ?? this.telegramLink,
      facebookLink: facebookLink ?? this.facebookLink,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      postCount: postCount,
      likeCount: likeCount ?? this.likeCount,
      isFollowing: isFollowing ?? this.isFollowing,
      skills: skills ?? this.skills,
      location: location ?? this.location,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      workplace: workplace ?? this.workplace,
      workplaces: workplaces ?? this.workplaces,
      workEntries: workEntries ?? this.workEntries,
      education: education ?? this.education,
      educationEntries: educationEntries ?? this.educationEntries,
      personalExtras: personalExtras ?? this.personalExtras,
      otherLinks: otherLinks ?? this.otherLinks,
      linkEntries: linkEntries ?? this.linkEntries,
      otherContacts: otherContacts ?? this.otherContacts,
      contactEntries: contactEntries ?? this.contactEntries,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isStudentVerified: isStudentVerified ?? this.isStudentVerified,
    );
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      fullName: json['full_name'] as String? ?? 'Unknown',
      bio: json['bio'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      university: json['university'] as String?,
      major: json['major'] as String?,
      graduationYear: json['graduation_year'] as int?,
      telegramLink: json['telegram_link'] as String?,
      facebookLink: json['facebook_link'] as String?,
      followerCount: json['follower_count'] as int? ?? 0,
      followingCount: json['following_count'] as int? ?? 0,
      postCount: json['post_count'] as int? ?? 0,
      likeCount: json['like_count'] as int? ?? json['stats']?['likes'] as int? ?? 0,
      isFollowing: json['is_following'] as bool? ?? false,
      location: json['location'] as String?,
      gender: json['gender'] as String?,
      skills: _skillsFromJson(json['skills']),
      isStudentVerified: json['is_student_verified'] as bool? ?? false,
    );
  }
}

List<ProfileSkill> _skillsFromJson(dynamic raw) {
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item is Map<String, dynamic>)
        ProfileSkill.fromJson(item)
      else if (item is Map)
        ProfileSkill.fromJson(Map<String, dynamic>.from(item)),
  ];
}

class ProfileSkill {
  const ProfileSkill({
    required this.name,
    required this.proficiency,
    this.colorValue,
    this.iconKey,
    this.iconPath,
    List<String>? attachmentPaths,
  }) : _attachmentPaths = attachmentPaths;

  final String name;

  /// AI-estimated proficiency (0–100). Set when the skill is created/updated.
  final int proficiency;

  /// ARGB color chosen by the user. `null` = auto / random from palette.
  final int? colorValue;

  /// Catalog id used to resolve the skill logo (e.g. `java`, `flutter`).
  final String? iconKey;

  /// Optional local custom icon path (Other / user-uploaded).
  final String? iconPath;

  final List<String>? _attachmentPaths;

  /// Linked proof files — never null (guards hot-reload / legacy payloads).
  List<String> get attachmentPaths => _attachmentPaths ?? const [];

  ProfileSkill copyWith({
    String? name,
    int? proficiency,
    int? colorValue,
    String? iconKey,
    String? iconPath,
    List<String>? attachmentPaths,
    bool clearColorValue = false,
  }) {
    return ProfileSkill(
      name: name ?? this.name,
      proficiency: proficiency ?? this.proficiency,
      colorValue: clearColorValue ? null : (colorValue ?? this.colorValue),
      iconKey: iconKey ?? this.iconKey,
      iconPath: iconPath ?? this.iconPath,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
    );
  }

  factory ProfileSkill.fromJson(Map<String, dynamic> json) {
    final rawAttachments = json['attachmentPaths'] ?? json['attachment_paths'];
    return ProfileSkill(
      name: json['name'] as String? ?? '',
      proficiency: json['proficiency'] as int? ?? 0,
      colorValue: json['colorValue'] as int? ?? json['color_value'] as int?,
      iconKey: json['iconKey'] as String? ?? json['icon_key'] as String?,
      iconPath: json['iconPath'] as String? ?? json['icon_path'] as String?,
      attachmentPaths: _stringListFromJson(rawAttachments),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'proficiency': proficiency,
        if (colorValue != null) 'colorValue': colorValue,
        if (iconKey != null) 'iconKey': iconKey,
        if (iconPath != null) 'iconPath': iconPath,
        if (attachmentPaths.isNotEmpty) 'attachmentPaths': attachmentPaths,
      };
}

List<String> _stringListFromJson(dynamic raw) {
  if (raw is! List) return const [];
  return [
    for (final item in raw)
      if (item != null) item.toString(),
  ];
}

class ProfileWorkEntry {
  const ProfileWorkEntry({
    required this.workplace,
    this.position = '',
    this.description,
  });

  final String position;
  final String workplace;
  final String? description;

  String get displayLabel {
    final p = position.trim();
    final w = workplace.trim();
    if (p.isNotEmpty && w.isNotEmpty) return '$p · $w';
    if (w.isNotEmpty) return w;
    return p;
  }
}

class ProfileEducationEntry {
  const ProfileEducationEntry({
    required this.school,
    this.major,
    this.certificate,
    this.description,
  });

  final String school;
  final String? major;
  final String? certificate;
  final String? description;
}

class ProfileLinkEntry {
  const ProfileLinkEntry({
    required this.platform,
    required this.url,
  });

  final String platform;
  final String url;
}

class ProfileContactEntry {
  const ProfileContactEntry({
    this.phone,
    this.email,
  });

  final String? phone;
  final String? email;

  String get displayLabel {
    final parts = <String>[
      if (phone != null && phone!.trim().isNotEmpty) phone!.trim(),
      if (email != null && email!.trim().isNotEmpty) email!.trim(),
    ];
    return parts.join(' · ');
  }
}

class AppliedJobSummary {
  const AppliedJobSummary({
    required this.id,
    required this.jobPostId,
    required this.jobTitle,
    required this.company,
    required this.status,
    required this.appliedAt,
    this.location,
    this.employmentType,
    this.mediaUrl,
  });

  final String id;
  final String jobPostId;
  final String jobTitle;
  final String company;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String? location;
  final String? employmentType;
  final String? mediaUrl;
}

class CvMetadataModel {
  const CvMetadataModel({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    this.downloadUrl,
    this.templateId,
    this.createdAt,
    this.isDefault = false,
    this.isAiGenerated = false,
  });

  final String fileId;
  final String fileName;
  final String mimeType;
  final String? downloadUrl;

  /// Gallery template used when this CV was generated / blank-created.
  final String? templateId;
  final DateTime? createdAt;
  final bool isDefault;
  final bool isAiGenerated;

  bool get isPdf => mimeType.contains('pdf');

  CvMetadataModel copyWith({
    String? fileId,
    String? fileName,
    String? mimeType,
    String? downloadUrl,
    String? templateId,
    DateTime? createdAt,
    bool? isDefault,
    bool? isAiGenerated,
  }) {
    return CvMetadataModel(
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      mimeType: mimeType ?? this.mimeType,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      isDefault: isDefault ?? this.isDefault,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
    );
  }
}

enum ApplicationStatus { pending, reviewed, accepted, rejected }

class JobApplicationModel {
  const JobApplicationModel({
    required this.id,
    required this.jobPostId,
    required this.applicantName,
    this.applicantUserId,
    this.headline,
    this.location,
    this.email,
    required this.appliedAt,
    this.status = ApplicationStatus.pending,
    this.cvFileName,
    this.rank = 1,
  });

  final String id;
  final String jobPostId;
  final String applicantName;
  final String? applicantUserId;
  final String? headline;
  final String? location;
  final String? email;
  final DateTime appliedAt;
  final ApplicationStatus status;
  final String? cvFileName;
  final int rank;

  JobApplicationModel copyWith({ApplicationStatus? status}) {
    return JobApplicationModel(
      id: id,
      jobPostId: jobPostId,
      applicantName: applicantName,
      applicantUserId: applicantUserId,
      headline: headline,
      location: location,
      email: email,
      appliedAt: appliedAt,
      status: status ?? this.status,
      cvFileName: cvFileName,
      rank: rank,
    );
  }
}
