import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/fixtures/comment_fixtures.dart';
import 'package:aub_connect_app/data/fixtures/post_fixtures.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/services/post_service.dart';

class FeedPageResult {
  const FeedPageResult({required this.posts, required this.hasMore});

  final List<FeedPost> posts;
  final bool hasMore;
}

class PostRepository {
  PostRepository(
    this._postService,
    this._currentUser,
    this._flags,
    this._localStorage,
  );

  final PostService _postService;
  final CurrentUserService _currentUser;
  final FeatureFlags _flags;
  final LocalStorageService _localStorage;

  bool get useMockApi => _flags.useMockApi;

  final _mockComments = <String, List<CommentModel>>{};
  final _mockCreatedPosts = <String, FeedPost>{};
  final _mockPostOverrides = <String, FeedPost>{};
  /// Survives across repository recreations within the same isolate when static.
  static final _mockDeletedPostIds = <String>{};
  final _followedAuthors = <String>{};
  final _reactedPosts = <String>{};
  var _mockSeeded = false;
  static Future<void>? _mockPersistenceFuture;

  String get _mockUserId => _currentUser.userId;

  void _ensureMockSeed() {
    if (_mockSeeded) return;
    _mockSeeded = true;
    for (final entry in CommentFixtures.buildComments().entries) {
      _mockComments[entry.key] = List<CommentModel>.from(entry.value);
    }
  }

  Future<void> _ensureMockReady() async {
    _ensureMockSeed();
    if (!useMockApi) return;
    _mockPersistenceFuture ??= _loadMockPersistence();
    await _mockPersistenceFuture;
  }

  /// Demo: wipe persisted deletes and show all fixture posts again.
  Future<void> restoreAllMockPosts() async {
    _mockDeletedPostIds.clear();
    _mockPersistenceFuture = null;
    await _localStorage.clearMockDeletedPostIds();
    await _ensureMockReady();
  }

  /// Loads persisted mock deletes before any feed/profile read.
  Future<void> hydrateMockState({bool restoreCatalogIfNeeded = false}) async {
    if (restoreCatalogIfNeeded && useMockApi) {
      final restored = await _localStorage.consumeMockCatalogRestore();
      if (restored) {
        await restoreAllMockPosts();
        return;
      }
    }
    await _ensureMockReady();
  }

  Future<void> _loadMockPersistence() async {
    final ids = await _localStorage.readMockDeletedPostIds();
    _mockDeletedPostIds
      ..clear()
      ..addAll(ids);
  }

  Future<FeedPageResult> fetchUserPosts({
    required String userId,
    required PostType type,
    required int page,
    int limit = 10,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockReady();
      final all = _applyMockPostState([
        ..._mockCreatedPosts.values,
        ...PostFixtures.allPosts(
          currentUserId: _mockUserId,
          reactedPosts: _reactedPosts,
          followedAuthors: _followedAuthors,
        ),
      ]);
      List<FeedPost> typed;
      if (userId == _mockUserId) {
        // Demo profile: show full mock catalog for this tab, owned by HR user.
        typed = all.where((p) => p.type == type).map((p) {
          return FeedPost(
            id: p.id,
            type: p.type,
            author: _currentUser.postAuthor,
            content: p.content,
            mediaUrl: p.mediaUrl,
            thumbnailUrl: p.thumbnailUrl,
            durationSeconds: p.durationSeconds,
            jobMeta: p.jobMeta,
            applicantCount: p.applicantCount,
            createdAt: p.createdAt,
            reactionCount: p.reactionCount,
            commentCount: p.commentCount,
            shareCount: p.shareCount,
            applicationState: p.applicationState,
            lifecycleState: p.lifecycleState,
            currentUserId: _mockUserId,
          );
        }).toList();
      } else {
        typed =
            all.where((p) => p.author.id == userId && p.type == type).toList();
      }
      final start = (page - 1) * limit;
      final slice = typed.skip(start).take(limit).toList();
      return FeedPageResult(
          posts: slice, hasMore: start + limit < typed.length);
    }

    final posts = await _postService.getUserPosts(
      userId: userId,
      type: type,
      page: page,
      limit: limit,
      currentUserId: _mockUserId,
    );
    return FeedPageResult(posts: posts, hasMore: posts.length >= limit);
  }

  Future<FeedPageResult> fetchFeed({required int page, int limit = 10}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await _ensureMockReady();
      if (page < 1) return const FeedPageResult(posts: [], hasMore: false);
      if (page > 2) return const FeedPageResult(posts: [], hasMore: false);
      final fixturePosts = PostFixtures.feedPage(
        page: page,
        currentUserId: _mockUserId,
        reactedPosts: _reactedPosts,
        followedAuthors: _followedAuthors,
      );
      if (fixturePosts.isEmpty && page > 1) {
        return const FeedPageResult(posts: [], hasMore: false);
      }
      final posts = _applyMockPostState([
        if (page == 1) ..._mockCreatedPosts.values,
        ...fixturePosts,
      ]);
      return FeedPageResult(
        posts: posts,
        hasMore: PostFixtures.feedHasMore(
          page: page,
          currentUserId: _mockUserId,
        ),
      );
    }

    final posts = await _postService.fetchFeed(
        page: page, limit: limit, currentUserId: _mockUserId);
    return FeedPageResult(posts: posts, hasMore: posts.length >= limit);
  }

  /// Video-only feed for the Reels tab. The home feed first page is mostly
  /// jobs, so filtering that page would show an empty Reels screen.
  Future<FeedPageResult> fetchReels({required int page, int limit = 20}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _ensureMockSeed();
      if (page < 1) return const FeedPageResult(posts: [], hasMore: false);
      final all = _applyMockPostState([
        ..._mockCreatedPosts.values,
        ...PostFixtures.allPosts(
          currentUserId: _mockUserId,
          reactedPosts: _reactedPosts,
          followedAuthors: _followedAuthors,
        ),
      ]).where((p) => p.type == PostType.video).toList();
      final start = (page - 1) * limit;
      if (start >= all.length) {
        return const FeedPageResult(posts: [], hasMore: false);
      }
      return FeedPageResult(
        posts: all.skip(start).take(limit).toList(),
        hasMore: start + limit < all.length,
      );
    }

    final posts = await _postService.fetchFeed(
      page: page,
      limit: limit,
      currentUserId: _mockUserId,
      type: PostType.video,
    );
    return FeedPageResult(posts: posts, hasMore: posts.length >= limit);
  }

  Future<void> toggleReaction(String postId) async {
    if (useMockApi) {
      if (_reactedPosts.contains(postId)) {
        _reactedPosts.remove(postId);
      } else {
        _reactedPosts.add(postId);
      }
      return;
    }
    await _postService.toggleReaction(postId);
  }

  bool isReacted(String postId) => _reactedPosts.contains(postId);

  Future<void> setFollow(String authorId, bool follow) async {
    if (useMockApi) {
      if (follow) {
        _followedAuthors.add(authorId);
      } else {
        _followedAuthors.remove(authorId);
      }
      return;
    }
    if (follow) {
      await _postService.followUser(authorId);
    } else {
      await _postService.unfollowUser(authorId);
    }
  }

  bool isFollowing(String authorId) => _followedAuthors.contains(authorId);

  Future<FeedPost?> fetchPost(String postId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockReady();
      if (_mockDeletedPostIds.contains(postId)) return null;
      final local = _mockCreatedPosts[postId] ?? _mockPostOverrides[postId];
      if (local != null) return local;
      return PostFixtures.findPost(
        postId,
        currentUserId: _mockUserId,
        reactedPosts: _reactedPosts,
        followedAuthors: _followedAuthors,
      );
    }
    return _postService.fetchPost(postId, currentUserId: _mockUserId);
  }

  Future<List<CommentModel>> fetchComments(String postId,
      {int page = 1}) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      await _ensureMockReady();
      return List<CommentModel>.from(_mockComments[postId] ?? []);
    }
    return _postService.fetchComments(postId: postId, page: page, limit: 20);
  }

  Future<CommentModel> createComment({
    required String postId,
    required String text,
    required PostAuthor currentUser,
    String? parentCommentId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 500));
      final comment = CommentModel(
        id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
        postId: postId,
        author: currentUser,
        text: text,
        createdAt: DateTime.now(),
        parentCommentId: parentCommentId,
      );
      final list = _mockComments.putIfAbsent(postId, () => []);
      if (parentCommentId == null || parentCommentId.isEmpty) {
        list.insert(0, comment);
      } else {
        final insertAt = _replyInsertIndex(list, parentCommentId);
        list.insert(insertAt, comment);
      }
      return comment;
    }
    return _postService.createComment(
      postId: postId,
      text: text,
      parentCommentId: parentCommentId,
    );
  }

  int _replyInsertIndex(List<CommentModel> list, String parentCommentId) {
    final parentIndex = list.indexWhere((c) => c.id == parentCommentId);
    if (parentIndex < 0) return 0;
    var insertAt = parentIndex + 1;
    while (insertAt < list.length &&
        list[insertAt].parentCommentId == parentCommentId) {
      insertAt++;
    }
    return insertAt;
  }

  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      await _ensureMockReady();
      final list = _mockComments[postId];
      if (list == null) {
        throw PostServiceException('Comment not found');
      }
      final index = list.indexWhere((c) => c.id == commentId);
      if (index < 0) {
        throw PostServiceException('Comment not found');
      }
      final updated = list[index].copyWith(text: text);
      list[index] = updated;
      return updated;
    }
    return _postService.updateComment(
      postId: postId,
      commentId: commentId,
      text: text,
    );
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await _ensureMockReady();
      final list = _mockComments[postId];
      if (list == null) return;
      list.removeWhere(
        (c) => c.id == commentId || c.parentCommentId == commentId,
      );
      return;
    }
    await _postService.deleteComment(postId: postId, commentId: commentId);
  }

  Future<FeedPost> createPost({
    required PostType type,
    required String content,
    String? mediaFileId,
    JobMeta? jobMeta,
    DateTime? scheduledAt,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      final hasMedia = mediaFileId != null && mediaFileId.isNotEmpty;
      final post = FeedPost(
        id: 'post-${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        author: _currentUser.postAuthor,
        content: content,
        // Text-only posts must not invent a placeholder image.
        mediaUrl: hasMedia ? mediaFileId : null,
        thumbnailUrl: hasMedia ? mediaFileId : null,
        durationSeconds: hasMedia && type == PostType.video ? 125 : 0,
        jobMeta: type == PostType.job
            ? (jobMeta ?? const JobMeta(title: 'Job announcement!'))
            : const JobMeta(),
        createdAt: DateTime.now(),
        currentUserId: _mockUserId,
      );
      _mockCreatedPosts[post.id] = post;
      return post;
    }

    return _postService.createPost(
      type: type.name.toUpperCase(),
      content: content,
      mediaFileId: mediaFileId,
      scheduledAt: scheduledAt,
      jobMeta: jobMeta != null
          ? {
              if (jobMeta.title != null) 'title': jobMeta.title,
              if (jobMeta.description != null)
                'description': jobMeta.description,
            }
          : null,
      currentUserId: _mockUserId,
    );
  }

  Future<FeedPost> updatePost({
    required String postId,
    required String content,
    String? mediaFileId,
    bool removeMedia = false,
    JobMeta? jobMeta,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      final current = await fetchPost(postId);
      if (current == null) throw PostServiceException('Post not found');
      if (!current.isOwnPost) {
        throw PostServiceException('You can only edit your own post');
      }
      final mediaUrl = removeMedia ? null : (mediaFileId ?? current.mediaUrl);
      final updated = current.copyWith(
        content: content,
        mediaUrl: mediaUrl,
        thumbnailUrl: mediaUrl,
        jobMeta: current.type == PostType.job ? jobMeta : const JobMeta(),
      );
      if (_mockCreatedPosts.containsKey(postId)) {
        _mockCreatedPosts[postId] = updated;
      } else {
        _mockPostOverrides[postId] = updated;
      }
      return updated;
    }

    return _postService.updatePost(
      postId: postId,
      content: content,
      mediaFileId: mediaFileId,
      removeMedia: removeMedia,
      jobMeta: jobMeta != null
          ? {
              if (jobMeta.title != null) 'title': jobMeta.title,
              if (jobMeta.description != null)
                'description': jobMeta.description,
              if (jobMeta.requirement != null)
                'requirement': jobMeta.requirement,
            }
          : null,
      currentUserId: _mockUserId,
    );
  }

  Future<void> deletePost(String postId) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      await _ensureMockReady();
      final current = await fetchPost(postId);
      if (current == null) return;
      // Demo profile remaps fixture authors to the logged-in HR user, so skip
      // real ownership checks until the API owns delete.
      _mockDeletedPostIds.add(postId);
      _mockCreatedPosts.remove(postId);
      _mockPostOverrides.remove(postId);
      _mockComments.remove(postId);
      _reactedPosts.remove(postId);
      await _localStorage.saveMockDeletedPostIds(
        Set<String>.from(_mockDeletedPostIds),
      );
      return;
    }
    await _postService.deletePost(postId);
  }

  List<FeedPost> _applyMockPostState(List<FeedPost> posts) {
    final seen = <String>{};
    return posts
        .where((post) =>
            !_mockDeletedPostIds.contains(post.id) && seen.add(post.id))
        .map((post) => _mockPostOverrides[post.id] ?? post)
        .toList();
  }

  Future<void> sharePublicly(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }

  Future<void> savePrivately(String postId) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
  }
}
