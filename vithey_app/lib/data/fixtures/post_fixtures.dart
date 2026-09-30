import 'package:aub_connect_app/core/constants/app_assets.dart';
import 'package:aub_connect_app/data/fixtures/application_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/mock_clock.dart';
import 'package:aub_connect_app/data/fixtures/mock_ids.dart';
import 'package:aub_connect_app/data/fixtures/user_fixtures.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';

/// Feed / profile post mocks.
///
/// Usage split (no role picker):
/// - Logged-in user (**Poster / HR**): owns JOB posts `post-7`…`post-9`.
/// - `author-1` (**Applier / Student**): posters/videos only — no JOB posts.
/// - `post-10`, `post-19`, `post-20`: open jobs for Apply CV UI testing.
/// - `post-3`, `post-4`, `post-17`, `post-18`: seeded Applied Jobs for the logged-in user.
abstract final class PostFixtures {
  static const feedPageSize = 5;

  static List<FeedPost> allPosts({
    required String currentUserId,
    Set<String> reactedPosts = const {},
    Set<String> followedAuthors = const {},
  }) {
    final appliedIds = ApplicationFixtures.seedAppliedJobPostIds();

    return [
      // Apply CV demos — open jobs with Apply button (not seeded as applied).
      _job(
        id: MockIds.post10,
        authorId: MockIds.author3,
        title: 'Web Developer',
        company: 'Aeon Mall',
        employmentType: 'Full-time',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost1,
        applicantCount: 2,
        createdAt: MockClock.hoursAgo(2),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: JobApplicationState.notApplied,
      ),
      _job(
        id: MockIds.post19,
        authorId: MockIds.author5,
        title: 'Mobile App Developer',
        company: 'Pipay',
        employmentType: 'Full-time',
        location: 'Phnom Penh, BKK1',
        mediaUrl: AppAssets.jobPost2,
        applicantCount: 6,
        createdAt: MockClock.hoursAgo(4),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: JobApplicationState.notApplied,
      ),
      _job(
        id: MockIds.post20,
        authorId: MockIds.author6,
        title: 'Junior Data Analyst',
        company: 'ACLEDA Bank Plc.',
        employmentType: 'Internship',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost3,
        applicantCount: 11,
        createdAt: MockClock.hoursAgo(7),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: JobApplicationState.notApplied,
      ),
      // Own job — Applicants link on feed.
      _job(
        id: MockIds.post7,
        authorId: MockIds.currentUser,
        title: 'Call Center Officer',
        company: 'LOLC (Cambodia) Plc.',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost3,
        applicantCount: 8,
        createdAt: MockClock.monthsAgo(2),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _poster(
        id: MockIds.post1,
        authorId: MockIds.author1,
        content: 'Campus event this Friday! Join us for workshops and networking.',
        seed: 1,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post3,
        authorId: MockIds.author3,
        title: 'Frontend Developer',
        company: 'Chip Mong Group',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Head Office',
        mediaUrl: AppAssets.jobPost1,
        applicantCount: 5,
        createdAt: MockClock.hoursAgo(5),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: appliedIds.contains(MockIds.post3)
            ? JobApplicationState.applied
            : JobApplicationState.notApplied,
      ),
      _job(
        id: MockIds.post9,
        authorId: MockIds.currentUser,
        title: 'Marketing Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'Phnom Penh, 32nd Street, SMC',
        mediaUrl: AppAssets.jobPost2,
        applicantCount: 3,
        createdAt: MockClock.hoursAgo(18),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _video(
        id: MockIds.post2,
        authorId: MockIds.author2,
        content: 'Highlights from last week\'s student showcase.',
        seed: 2,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      ),
      _job(
        id: MockIds.post4,
        authorId: MockIds.author3,
        title: 'Sales (Credit Officer) Intern',
        company: 'KDSB',
        employmentType: 'Internship',
        location: 'KDSB Branches & Head Office',
        mediaUrl: AppAssets.jobPost2,
        applicantCount: 12,
        createdAt: MockClock.daysAgo(3),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: appliedIds.contains(MockIds.post4)
            ? JobApplicationState.applied
            : JobApplicationState.notApplied,
      ),
      _job(
        id: MockIds.post8,
        authorId: MockIds.currentUser,
        title: 'Young Talent, Finance',
        company: 'Chip Mong Group',
        employmentType: 'Internship',
        location: 'Phnom Penh',
        mediaUrl: AppAssets.jobPost1,
        applicantCount: 5,
        createdAt: MockClock.yearsAgo(1),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _job(
        id: MockIds.post17,
        authorId: MockIds.author5,
        title: 'UI/UX Designer',
        company: 'Smart Axiata',
        employmentType: 'Full-time',
        location: 'Phnom Penh',
        mediaUrl: AppAssets.jobPost3,
        applicantCount: 9,
        createdAt: MockClock.daysAgo(8),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: appliedIds.contains(MockIds.post17)
            ? JobApplicationState.applied
            : JobApplicationState.notApplied,
      ),
      _job(
        id: MockIds.post18,
        authorId: MockIds.author6,
        title: 'Content Marketing Associate',
        company: 'Wing Bank',
        employmentType: 'Full-time',
        location: 'Phnom Penh, Toul Kork',
        mediaUrl: AppAssets.jobPost2,
        applicantCount: 4,
        createdAt: MockClock.daysAgo(11),
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        applicationState: appliedIds.contains(MockIds.post18)
            ? JobApplicationState.applied
            : JobApplicationState.notApplied,
      ),
      _video(
        id: MockIds.post5,
        authorId: MockIds.currentUser,
        content: 'Student showcase highlights from last week.',
        seed: 5,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      ),
      _poster(
        id: MockIds.post16,
        authorId: MockIds.currentUser,
        content:
            'We are hiring! Join our team at Fintech Center — open roles for developers and analysts.',
        seed: 16,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
      _video(
        id: MockIds.post11,
        authorId: MockIds.author1,
        content: 'Campus walk — AUB morning vibes ☀️',
        seed: 11,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        commentCount: 38,
        shareCount: 354,
        reactionCount: 1200,
      ),
      _video(
        id: MockIds.post12,
        authorId: MockIds.author5,
        content: 'Quick tip for your next interview. Save this for later!',
        seed: 12,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        commentCount: 56,
        shareCount: 89,
        reactionCount: 430,
      ),
      _video(
        id: MockIds.post13,
        authorId: MockIds.author6,
        content: 'Behind the scenes at the career fair.',
        seed: 13,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        commentCount: 12,
        shareCount: 24,
        reactionCount: 210,
      ),
      _video(
        id: MockIds.post14,
        authorId: MockIds.author8,
        content: 'Study with me — library session 📚',
        seed: 14,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        commentCount: 77,
        shareCount: 41,
        reactionCount: 890,
      ),
      _video(
        id: MockIds.post15,
        authorId: MockIds.author1,
        content: 'CCNA study notes — network topology basics',
        seed: 15,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
        mediaUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        commentCount: 24,
        shareCount: 18,
        reactionCount: 640,
      ),
      _poster(
        id: MockIds.post6,
        authorId: MockIds.author1,
        content: 'Heng Liza design portfolio launch event this weekend.',
        seed: 6,
        currentUserId: currentUserId,
        reactedPosts: reactedPosts,
        followedAuthors: followedAuthors,
      ),
    ];
  }

  static List<FeedPost> feedPage({
    required int page,
    required String currentUserId,
    Set<String> reactedPosts = const {},
    Set<String> followedAuthors = const {},
  }) {
    final all = allPosts(
      currentUserId: currentUserId,
      reactedPosts: reactedPosts,
      followedAuthors: followedAuthors,
    );
    if (page < 1) return [];
    final start = (page - 1) * feedPageSize;
    if (start >= all.length) return [];
    return all.skip(start).take(feedPageSize).toList();
  }

  static bool feedHasMore({
    required int page,
    required String currentUserId,
  }) {
    final total = allPosts(currentUserId: currentUserId).length;
    return page * feedPageSize < total;
  }

  static FeedPost? findPost(
    String postId, {
    required String currentUserId,
    Set<String> reactedPosts = const {},
    Set<String> followedAuthors = const {},
  }) {
    for (final post in allPosts(
      currentUserId: currentUserId,
      reactedPosts: reactedPosts,
      followedAuthors: followedAuthors,
    )) {
      if (post.id == postId) return post;
    }
    return null;
  }

  static FeedPost _poster({
    required String id,
    required String authorId,
    required String content,
    required int seed,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
  }) {
    return FeedPost(
      id: id,
      type: PostType.poster,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: content,
      mediaUrl: 'https://picsum.photos/seed/poster$seed/600/420',
      createdAt: MockClock.hoursAgo(seed * 2),
      viewCount: 180 + seed * 37,
      reactionCount: 12 + seed,
      commentCount: 3 + seed,
      shareCount: seed,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }

  static FeedPost _video({
    required String id,
    required String authorId,
    required String content,
    required int seed,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
    String? mediaUrl,
    int? reactionCount,
    int? commentCount,
    int? shareCount,
  }) {
    return FeedPost(
      id: id,
      type: PostType.video,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: content,
      mediaUrl: mediaUrl ??
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://picsum.photos/seed/vthumb$seed/600/340',
      durationSeconds: 95 + seed,
      createdAt: MockClock.hoursAgo(seed * 3),
      viewCount: reactionCount != null
          ? reactionCount * 14 + 320
          : 520 + seed * 91,
      reactionCount: reactionCount ?? (45 + seed),
      commentCount: commentCount ?? 8,
      shareCount: shareCount ?? 2,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }

  static FeedPost _job({
    required String id,
    required String authorId,
    required String title,
    required String company,
    required String employmentType,
    required String location,
    required String mediaUrl,
    required int applicantCount,
    required DateTime createdAt,
    required String currentUserId,
    required Set<String> reactedPosts,
    required Set<String> followedAuthors,
    JobApplicationState applicationState = JobApplicationState.notApplied,
  }) {
    return FeedPost(
      id: id,
      type: PostType.job,
      author: PostAuthor(id: authorId, fullName: UserFixtures.displayName(authorId)),
      content: location,
      mediaUrl: mediaUrl,
      jobMeta: JobMeta(
        title: title,
        description: '$company · $employmentType · $location',
        requirement: employmentType,
      ),
      applicantCount: applicantCount,
      applicationState: applicationState,
      createdAt: createdAt,
      reactionCount: 20,
      commentCount: 4,
      shareCount: 1,
      userReacted: reactedPosts.contains(id),
      isFollowingAuthor: followedAuthors.contains(authorId),
      currentUserId: currentUserId,
    );
  }
}
