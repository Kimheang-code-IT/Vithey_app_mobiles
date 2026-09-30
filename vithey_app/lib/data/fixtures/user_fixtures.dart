import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/models/chat_participant.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/models/user_model.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

/// Profile / author mocks.
///
/// Logged-in user = Poster (HR) demo. `author-1` = Applier (Student) demo.
/// Same screens for everyone; Jobs vs Applied Jobs content follows usage.
abstract final class UserFixtures {
  /// Mock IT skills for Khorn Molika (User 1 — own profile All tab).
  static const mockItSkills = <ProfileSkill>[
    ProfileSkill(name: 'Flutter', proficiency: 75, iconKey: 'flutter'),
    ProfileSkill(name: 'HTML', proficiency: 50, iconKey: 'html'),
    ProfileSkill(name: 'Spring Boot', proficiency: 60, iconKey: 'spring'),
    ProfileSkill(name: 'React', proficiency: 80, iconKey: 'react'),
    ProfileSkill(name: 'Dart', proficiency: 70, iconKey: 'dart'),
    ProfileSkill(name: 'Java', proficiency: 65, iconKey: 'java'),
    ProfileSkill(name: 'PostgreSQL', proficiency: 55, iconKey: 'postgresql'),
    ProfileSkill(name: 'Docker', proficiency: 50, iconKey: 'docker'),
  ];

  /// Mock skills for Heng Liza (User 2 — view profile All tab).
  static const lizaMockSkills = <ProfileSkill>[
    ProfileSkill(name: 'Flutter', proficiency: 75, iconKey: 'flutter'),
    ProfileSkill(name: 'HTML', proficiency: 50, iconKey: 'html'),
    ProfileSkill(name: 'Spring Boot', proficiency: 60, iconKey: 'spring'),
    ProfileSkill(name: 'React', proficiency: 80, iconKey: 'react'),
  ];

  static const currentUserAuthor = PostAuthor(
    id: MockIds.currentUser,
    fullName: MockIdentities.mockUserFullName,
  );

  static UserModel currentUser({String? email, String? fullName}) {
    return UserModel(
      id: MockIds.currentUser,
      email: email ?? MockIdentities.mockUserEmail,
      fullName: fullName ?? MockIdentities.mockUserFullName,
      role: 'USER',
    );
  }

  static PostAuthor authorFor(String userId) {
    if (userId == MockIds.currentUser && Get.isRegistered<CurrentUserService>()) {
      return Get.find<CurrentUserService>().postAuthor;
    }
    return PostAuthor(id: userId, fullName: displayName(userId));
  }

  static String displayName(String userId) {
    if (userId == MockIds.currentUser && Get.isRegistered<CurrentUserService>()) {
      return Get.find<CurrentUserService>().displayName;
    }
    return switch (userId) {
      MockIds.currentUser => MockIdentities.mockUserFullName,
      MockIds.author1 => 'Heng Liza',
      MockIds.author2 => 'Molika Khorn',
      MockIds.author3 => 'AUB Career Center',
      MockIds.author4 => 'Sreynich Chan',
      MockIds.author5 => 'Meas Lily',
      MockIds.author6 => 'Ponloeng Bora',
      MockIds.author7 => 'Moeng Kimheang',
      MockIds.author8 => 'Sokha Phan',
      MockIds.author9 => 'Dara Lim',
      MockIds.author10 => 'Vanna Chea',
      MockIds.author11 => 'Pisey Nget',
      MockIds.author12 => 'Rith Sok',
      MockIds.author13 => 'Sophea Keo',
      MockIds.author14 => 'New Contact',
      MockIds.author15 => 'Study Group AUB',
      _ => 'Unknown',
    };
  }

  static Map<String, UserProfileModel> buildProfiles() {
    return {
      MockIds.currentUser: UserProfileModel(
        id: MockIds.currentUser,
        fullName: MockIdentities.mockUserFullName,
        bio: 'Main character of my life is no one else but me.',
        university: 'ACLEDA University of Business',
        major: 'Computer Science',
        graduationYear: 2026,
        telegramLink: 'https://t.me/khornmolika',
        facebookLink: 'https://facebook.com/khornmolika',
        followerCount: 40000,
        followingCount: 3800,
        likeCount: 128000,
        postCount: 31,
        location: 'Kambol, Phnom Penh',
        gender: 'Male',
        dateOfBirth: DateTime(2004, 8, 1),
        workplace: 'Fintech Center',
        workEntries: const [
          ProfileWorkEntry(
            position: 'Web Developer',
            workplace: 'Fintech Center',
          ),
        ],
        education: const [
          'Champuvorn High School',
          'ACLEDA University of Business',
          'Institute of Science and Technology Advanced',
        ],
        educationEntries: const [
          ProfileEducationEntry(school: 'Champuvorn High School'),
          ProfileEducationEntry(
            school: 'ACLEDA University of Business',
            major: 'Computer Science',
            certificate: 'Bachelor',
          ),
          ProfileEducationEntry(
            school: 'Institute of Science and Technology Advanced',
          ),
        ],
        linkEntries: const [
          ProfileLinkEntry(
            platform: 'Website',
            url: 'https://www.khornmolika.com',
          ),
          ProfileLinkEntry(
            platform: 'Telegram',
            url: 'https://t.me/khornmolika',
          ),
          ProfileLinkEntry(
            platform: 'Facebook',
            url: 'https://facebook.com/khornmolika',
          ),
        ],
        contactEntries: [
          ProfileContactEntry(
            phone: '098 765 432',
            email: MockIdentities.mockUserEmail,
          ),
        ],
        portfolioUrl: 'https://www.khornmolika.com',
        phone: '098 765 432',
        email: MockIdentities.mockUserEmail,
        isStudentVerified: false,
        skills: List<ProfileSkill>.of(mockItSkills),
      ),
      MockIds.author1: UserProfileModel(
        id: MockIds.author1,
        fullName: 'Heng Liza',
        bio: 'Main character of my life is no one else but me.',
        university: 'ACLEDA University of Business',
        major: 'Computer Science',
        graduationYear: 2027,
        telegramLink: 'https://t.me/hengliza',
        facebookLink: 'https://facebook.com/hengliza',
        followerCount: 8000,
        followingCount: 1000,
        likeCount: 10000,
        postCount: 24,
        location: 'Pur Senchey, Phnom Penh',
        gender: 'Female',
        dateOfBirth: DateTime(2005, 9, 1),
        workplace: 'Koala Coffee',
        workEntries: const [
          ProfileWorkEntry(
            position: 'Barista & Social Media',
            workplace: 'Koala Coffee',
          ),
        ],
        education: const [
          'Champuvorn High School',
          'ACLEDA University of Business',
          'Institute of Science and Technology Advanced',
        ],
        educationEntries: const [
          ProfileEducationEntry(school: 'Champuvorn High School'),
          ProfileEducationEntry(
            school: 'ACLEDA University of Business',
            major: 'Computer Science',
          ),
          ProfileEducationEntry(
            school: 'Institute of Science and Technology Advanced',
          ),
        ],
        linkEntries: const [
          ProfileLinkEntry(
            platform: 'Website',
            url: 'https://www.hengliza.com',
          ),
        ],
        contactEntries: const [
          ProfileContactEntry(
            phone: '012 345 678',
            email: 'hengliza81@gmail.com',
          ),
        ],
        portfolioUrl: 'https://www.hengliza.com',
        phone: '012 345 678',
        email: 'hengliza81@gmail.com',
        isStudentVerified: false,
        skills: List<ProfileSkill>.of(lizaMockSkills),
      ),
      MockIds.author2: const UserProfileModel(
        id: MockIds.author2,
        fullName: 'Molika Khorn',
        bio: 'Content creator sharing student life and career tips.',
        university: 'American University of Phnom Penh',
        major: 'Media Communications',
        graduationYear: 2026,
        followerCount: 512,
        followingCount: 180,
        postCount: 31,
      ),
      MockIds.author3: const UserProfileModel(
        id: MockIds.author3,
        fullName: 'AUB Career Center',
        bio: 'Official career opportunities and hiring announcements for AUB students.',
        university: 'American University of Phnom Penh',
        major: 'Career Services',
        followerCount: 890,
        followingCount: 12,
        postCount: 18,
      ),
      MockIds.author4: const UserProfileModel(
        id: MockIds.author4,
        fullName: 'Sreynich Chan',
        bio: 'Business student interested in campus events and networking.',
        university: 'American University of Phnom Penh',
        major: 'Business Administration',
        graduationYear: 2026,
        followerCount: 320,
        followingCount: 210,
        postCount: 8,
        location: 'Phnom Penh',
      ),
      MockIds.author5: const UserProfileModel(
        id: MockIds.author5,
        fullName: 'Meas Lily',
        bio: 'Business student at AUB.',
        university: 'American University of Phnom Penh',
        major: 'Business Administration',
        graduationYear: 2026,
        followerCount: 180,
        followingCount: 95,
        postCount: 6,
      ),
      MockIds.author6: const UserProfileModel(
        id: MockIds.author6,
        fullName: 'Ponloeng Bora',
        bio: 'Software engineering student.',
        university: 'American University of Phnom Penh',
        major: 'Computer Science',
        graduationYear: 2027,
        followerCount: 240,
        followingCount: 120,
        postCount: 11,
      ),
      MockIds.author7: const UserProfileModel(
        id: MockIds.author7,
        fullName: 'Moeng Kimheang',
        bio: 'Campus ambassador and event volunteer.',
        university: 'American University of Phnom Penh',
        major: 'Computer Science',
        graduationYear: 2026,
        followerCount: 410,
        followingCount: 260,
        postCount: 14,
        location: 'Phnom Penh',
      ),
    };
  }

  static List<PostAuthor> mentionUsers() {
    return [
      authorFor(MockIds.author1),
      authorFor(MockIds.author2),
      authorFor(MockIds.author3),
      authorFor(MockIds.author4),
      authorFor(MockIds.author5),
      authorFor(MockIds.author7),
    ];
  }

  static List<UserSearchResult> searchUsers() {
    return [
      const UserSearchResult(
        userId: MockIds.author1,
        fullName: 'Heng Liza',
        university: 'American University of Phnom Penh',
        major: 'Web Development',
        headline: 'Graphic designer · AUB',
      ),
      UserSearchResult(
        userId: MockIds.currentUser,
        fullName: MockIdentities.mockUserFullName,
        university: 'ACLEDA University of Business',
        major: 'Computer Science',
        headline: 'Fintech developer',
      ),
      const UserSearchResult(
        userId: MockIds.author4,
        fullName: 'Sreynich Chan',
        university: 'American University of Phnom Penh',
        major: 'Business Administration',
        headline: 'Business student at AUB',
      ),
      const UserSearchResult(
        userId: MockIds.author2,
        fullName: 'Molika Khorn',
        university: 'American University of Phnom Penh',
        major: 'Media Communications',
        headline: 'Content creator',
      ),
      const UserSearchResult(
        userId: MockIds.author3,
        fullName: 'AUB Career Center',
        university: 'American University of Phnom Penh',
        major: 'Career Services',
        headline: 'Official career page',
      ),
      const UserSearchResult(
        userId: MockIds.author7,
        fullName: 'Moeng Kimheang',
        university: 'American University of Phnom Penh',
        major: 'Computer Science',
        headline: 'Campus ambassador',
      ),
    ];
  }

  static List<ChatParticipant> recentContacts() {
    return const [
      ChatParticipant(id: MockIds.author1, fullName: 'Heng Liza', isOnline: true),
      ChatParticipant(id: MockIds.author5, fullName: 'Meas Lily', isOnline: true),
      ChatParticipant(id: MockIds.author7, fullName: 'Moeng Kimheang', isOnline: true),
      ChatParticipant(id: MockIds.author6, fullName: 'Ponloeng Bora'),
      ChatParticipant(id: MockIds.author2, fullName: 'Molika Khorn', isOnline: true),
      ChatParticipant(id: MockIds.author8, fullName: 'Sokha Phan'),
      ChatParticipant(id: MockIds.author9, fullName: 'Dara Lim', isOnline: true),
      ChatParticipant(id: MockIds.author11, fullName: 'Pisey Nget'),
    ];
  }
}
