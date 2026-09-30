import 'package:aub_connect_app/data/models/feed_post.dart';

class UserSearchResult {
  const UserSearchResult({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    this.university,
    this.major,
    this.headline,
    this.followerCount,
    this.presenceLabel = 'last seen recently',
  });

  final String userId;
  final String fullName;
  final String? avatarUrl;
  final String? university;
  final String? major;
  final String? headline;
  final int? followerCount;
  final String presenceLabel;

  String get subtitle {
    if (headline != null && headline!.trim().isNotEmpty) return headline!;
    if (major != null && university != null) return '$major · $university';
    if (major != null) return major!;
    if (university != null) return university!;
    return presenceLabel;
  }

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String?,
      university: json['university'] as String?,
      major: json['major'] as String?,
      headline: json['headline'] as String?,
      followerCount: (json['follower_count'] as num?)?.toInt(),
    );
  }
}

class PostSearchResult {
  const PostSearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.authorName,
    this.thumbnailUrl,
    this.createdAt,
    this.jobCompany,
    this.jobLocation,
  });

  final String id;
  final PostType type;
  final String title;
  final String authorName;
  final String? thumbnailUrl;
  final DateTime? createdAt;
  final String? jobCompany;
  final String? jobLocation;

  factory PostSearchResult.fromFeedPost(FeedPost post) {
    final title = post.type == PostType.job
        ? (post.jobMeta.title ?? post.content)
        : post.content;
    return PostSearchResult(
      id: post.id,
      type: post.type,
      title: title,
      authorName: post.author.fullName,
      thumbnailUrl: post.thumbnailUrl ?? post.mediaUrl,
      createdAt: post.createdAt,
      jobCompany: post.author.fullName,
      jobLocation: post.jobMeta.description,
    );
  }
}

enum SearchRecentType { user, query }

class SearchRecentItem {
  const SearchRecentItem({
    required this.id,
    required this.type,
    required this.title,
    required this.accessedAt,
    this.userId,
    this.avatarUrl,
    this.followerCount,
    this.isPinned = false,
    this.pinnedAt,
  });

  final String id;
  final SearchRecentType type;
  final String title;
  final DateTime accessedAt;
  final String? userId;
  final String? avatarUrl;
  final int? followerCount;
  final bool isPinned;
  final DateTime? pinnedAt;

  bool get isUser => type == SearchRecentType.user;

  SearchRecentItem copyWith({
    DateTime? accessedAt,
    bool? isPinned,
    DateTime? pinnedAt,
  }) {
    final nextPinned = isPinned ?? this.isPinned;
    return SearchRecentItem(
      id: id,
      type: type,
      title: title,
      accessedAt: accessedAt ?? this.accessedAt,
      userId: userId,
      avatarUrl: avatarUrl,
      followerCount: followerCount,
      isPinned: nextPinned,
      pinnedAt: nextPinned ? (pinnedAt ?? this.pinnedAt) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'accessed_at': accessedAt.toIso8601String(),
        'user_id': userId,
        'avatar_url': avatarUrl,
        'follower_count': followerCount,
        'is_pinned': isPinned,
        'pinned_at': pinnedAt?.toIso8601String(),
      };

  factory SearchRecentItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] == 'query'
        ? SearchRecentType.query
        : SearchRecentType.user;
    final userId = json['user_id']?.toString();
    final title =
        json['title']?.toString() ?? json['full_name']?.toString() ?? '';
    return SearchRecentItem(
      id: json['id']?.toString() ??
          (type == SearchRecentType.user
              ? 'user:${userId ?? ''}'
              : 'query:${title.trim().toLowerCase()}'),
      type: type,
      title: title,
      accessedAt: DateTime.tryParse(
            json['accessed_at']?.toString() ??
                json['visited_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      userId: userId,
      avatarUrl: json['avatar_url'] as String?,
      followerCount: (json['follower_count'] as num?)?.toInt(),
      isPinned: json['is_pinned'] as bool? ?? false,
      pinnedAt: DateTime.tryParse(json['pinned_at']?.toString() ?? ''),
    );
  }

  UserSearchResult toSearchResult() => UserSearchResult(
        userId: userId ?? '',
        fullName: title,
        avatarUrl: avatarUrl,
      );
}

class SearchResultsBundle {
  const SearchResultsBundle({
    this.people = const [],
    this.posts = const [],
    this.jobs = const [],
    this.videos = const [],
  });

  final List<UserSearchResult> people;
  final List<PostSearchResult> posts;
  final List<PostSearchResult> jobs;
  final List<PostSearchResult> videos;

  bool get isEmpty =>
      people.isEmpty && posts.isEmpty && jobs.isEmpty && videos.isEmpty;
}

class PaginatedResult<T> {
  const PaginatedResult({required this.items, required this.hasMore});

  final List<T> items;
  final bool hasMore;
}
