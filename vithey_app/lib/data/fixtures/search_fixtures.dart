import 'package:aub_connect_app/core/constants/mock_identities.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';

abstract final class SearchFixtures {
  static List<SearchRecentItem> defaultRecents() {
    return [
      SearchRecentItem(
        id: 'user:${MockIds.author1}',
        type: SearchRecentType.user,
        userId: MockIds.author1,
        title: UserFixtures.displayName(MockIds.author1),
        followerCount: 8000,
        accessedAt: MockClock.minutesAgo(5),
        isPinned: true,
        pinnedAt: MockClock.minutesAgo(6),
      ),
      SearchRecentItem(
        id: 'user:${MockIds.currentUser}',
        type: SearchRecentType.user,
        userId: MockIds.currentUser,
        title: MockIdentities.mockUserFullName,
        followerCount: 40000,
        accessedAt: MockClock.hoursAgo(1),
      ),
      SearchRecentItem(
        id: 'query:what is devops?',
        type: SearchRecentType.query,
        title: 'What is DevOps?',
        accessedAt: MockClock.hoursAgo(2),
      ),
      SearchRecentItem(
        id: 'user:${MockIds.author7}',
        type: SearchRecentType.user,
        userId: MockIds.author7,
        title: UserFixtures.displayName(MockIds.author7),
        followerCount: 4000,
        accessedAt: MockClock.hoursAgo(3),
      ),
      SearchRecentItem(
        id: 'query:job',
        type: SearchRecentType.query,
        title: 'Job',
        accessedAt: MockClock.hoursAgo(4),
      ),
    ];
  }

  static List<UserSearchResult> users() => UserFixtures.searchUsers();

  static List<PostSearchResult> posts() {
    return [
      PostSearchResult(
        id: MockIds.post1,
        type: PostType.poster,
        title: 'Workshop poster this Friday — join campus networking',
        authorName: UserFixtures.displayName(MockIds.author1),
        thumbnailUrl: 'https://picsum.photos/seed/poster1/120/120',
        createdAt: MockClock.hoursAgo(2),
      ),
      PostSearchResult(
        id: MockIds.post2,
        type: PostType.video,
        title: 'CCNA topology walkthrough for AUB students',
        authorName: UserFixtures.displayName(MockIds.author2),
        thumbnailUrl: 'https://picsum.photos/seed/vthumb2/160/90',
        createdAt: MockClock.hoursAgo(5),
      ),
      PostSearchResult(
        id: MockIds.post3,
        type: PostType.job,
        title: 'Multiple position · Aeon Mall',
        authorName: UserFixtures.displayName(MockIds.author3),
        thumbnailUrl: 'https://picsum.photos/seed/job3/120/120',
        jobCompany: 'Aeon Mall',
        jobLocation: 'Phnom Penh',
        createdAt: MockClock.daysAgo(1),
      ),
      PostSearchResult(
        id: MockIds.post4,
        type: PostType.job,
        title: 'Marketing Intern — summer program',
        authorName: UserFixtures.displayName(MockIds.author3),
        thumbnailUrl: 'https://picsum.photos/seed/job4/120/120',
        jobCompany: 'Global Tech Solutions',
        jobLocation: 'Pur Senchey',
        createdAt: MockClock.daysAgo(2),
      ),
      PostSearchResult(
        id: MockIds.post5,
        type: PostType.video,
        title: 'Student showcase highlights from last week',
        authorName: MockIdentities.mockUserFullName,
        thumbnailUrl: 'https://picsum.photos/seed/vthumb5/160/90',
        createdAt: MockClock.daysAgo(1),
      ),
      PostSearchResult(
        id: MockIds.post6,
        type: PostType.poster,
        title: 'Heng Liza design portfolio launch event',
        authorName: UserFixtures.displayName(MockIds.author1),
        thumbnailUrl: 'https://picsum.photos/seed/poster6/120/120',
        createdAt: MockClock.hoursAgo(8),
      ),
    ];
  }
}
