import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/widgets/confirm_dialog.dart';
import 'package:aub_connect_app/data/models/ai_feed_recommendation.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/post_mutation_result.dart';
import 'package:aub_connect_app/data/models/post_author.dart';
import 'package:aub_connect_app/data/models/profile_args.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_args.dart';
import 'package:aub_connect_app/modules/jobs/models/apply_cv_result.dart';
import 'package:aub_connect_app/data/repositories/ai_repository.dart';
import 'package:aub_connect_app/data/repositories/job_application_repository.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:aub_connect_app/modules/home/widgets/comment_sheet.dart';
import 'package:aub_connect_app/modules/home/widgets/home_media_header.dart';
import 'package:aub_connect_app/modules/home/widgets/share_sheet.dart';
import 'package:aub_connect_app/modules/home/create_post/models/create_post_args.dart';

class HomeController extends GetxController {
  HomeController(this._postRepository, this._jobApplicationRepository);

  final PostRepository _postRepository;
  final JobApplicationRepository _jobApplicationRepository;

  final posts = <FeedPost>[].obs;
  final isInitialLoading = true.obs;
  final isRefreshing = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final paginationError = false.obs;
  final activeVideoId = RxnString();
  final currentTab = MainTabNavigation.home.obs;

  int _page = 1;
  final _mutationPosts = <String>{};
  final _mutationAuthors = <String>{};

  PostAuthor get currentUser => Get.find<CurrentUserService>().postAuthor;

  /// Optional AI collaborators — resolved lazily so HomeBinding stays simple.
  FeatureFlags? get _featureFlags {
    try {
      return Get.find<FeatureFlags>();
    } catch (_) {
      return null;
    }
  }

  AiRepository? get _aiRepository {
    try {
      return Get.find<AiRepository>();
    } catch (_) {
      return null;
    }
  }

  /// Media circles for the flexible home header (Telegram-style).
  List<HomeMediaItem> get mediaStories {
    final me = currentUser;
    final items = <HomeMediaItem>[
      HomeMediaItem(
        id: 'own-media',
        label: 'Your media',
        imageUrl: me.avatarUrl,
        authorId: me.id,
        isOwn: true,
        hasUnseen: false,
      ),
    ];

    final seenAuthors = <String>{me.id};
    for (final post in posts) {
      if (post.type == PostType.job) continue;
      final preview =
          post.thumbnailUrl ?? post.mediaUrl ?? post.author.avatarUrl;
      if (preview == null || preview.isEmpty) {
        if (post.author.avatarUrl == null || post.author.avatarUrl!.isEmpty) {
          continue;
        }
      }
      if (!seenAuthors.add(post.author.id)) continue;

      final name = post.author.fullName.trim();
      final label = name.split(RegExp(r'\s+')).first;
      items.add(
        HomeMediaItem(
          id: 'media-${post.author.id}',
          label: label.isEmpty ? 'User' : label,
          imageUrl: preview ?? post.author.avatarUrl,
          postId: post.id,
          authorId: post.author.id,
          hasUnseen: true,
        ),
      );
      if (items.length >= 12) break;
    }
    return items;
  }

  void openMediaItem(HomeMediaItem item) {
    if (item.isOwn) {
      openCreatePost(type: PostType.poster);
      return;
    }
    if (item.postId != null && item.postId!.isNotEmpty) {
      openPost(item.postId!);
      return;
    }
    if (item.authorId != null && item.authorId!.isNotEmpty) {
      openAuthorProfile(item.authorId!);
    }
  }

  @override
  void onInit() {
    super.onInit();
    fetchInitialFeed();
    if (Get.isRegistered<NotificationRepository>()) {
      Get.find<NotificationRepository>().onAppResumed();
    }
  }

  Future<void> fetchInitialFeed() async {
    isInitialLoading.value = true;
    hasError.value = false;
    _page = 1;
    try {
      final result = await _postRepository.fetchFeed(page: _page);
      final normalized = await _applyLocalState(result.posts);
      posts.assignAll(await _applySmartRanking(normalized));
      hasMore.value = result.hasMore;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isInitialLoading.value = false;
    }
  }

  Future<void> refreshFeed() async {
    if (isRefreshing.value) return;
    isRefreshing.value = true;
    _page = 1;
    try {
      final result = await _postRepository.fetchFeed(page: _page);
      final normalized = await _applyLocalState(result.posts);
      posts.assignAll(await _applySmartRanking(normalized));
      hasMore.value = result.hasMore;
      hasError.value = false;
    } catch (e) {
      Get.snackbar(AppStrings.appName, e.toString());
    } finally {
      isRefreshing.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value || isInitialLoading.value) return;
    isLoadingMore.value = true;
    paginationError.value = false;
    try {
      _page += 1;
      final result = await _postRepository.fetchFeed(page: _page);
      final existingIds = posts.map((p) => p.id).toSet();
      final newPosts =
          result.posts.where((p) => !existingIds.contains(p.id)).toList();
      posts.addAll(await _applyLocalState(newPosts));
      hasMore.value = result.hasMore;
    } catch (e) {
      _page -= 1;
      paginationError.value = true;
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> retryFeed() => fetchInitialFeed();

  /// Ranks the page-1 feed using mock AI recommendations (AI-FEED-02/03),
  /// boosting apply-eligible skill-matched jobs near the top (AI-FEED-04).
  /// Falls back to the chronological order when AI is off/empty/fails
  /// (AI-FEED-07). Pagination pages stay chronological so dedupe works.
  Future<List<FeedPost>> _applySmartRanking(List<FeedPost> posts) async {
    if (posts.length < 2) return posts;

    final flags = _featureFlags;
    final ai = _aiRepository;
    if (flags == null || ai == null || !flags.useAiFeed) return posts;

    final List<AiFeedRecommendation> recs;
    try {
      recs = await ai.feedRecommendations();
    } catch (_) {
      return posts; // AI-FEED-07 chronological fallback.
    }
    if (recs.isEmpty) return posts;

    final byId = {for (final post in posts) post.id: post};
    final ranked = <FeedPost>[];
    final rankedIds = <String>{};
    for (final rec in recs) {
      final post = byId[rec.postId];
      if (post == null || !rankedIds.add(rec.postId)) continue;
      ranked.add(post);
    }
    if (ranked.isEmpty) return posts;

    // Enforce the job boost: open, apply-eligible jobs that exist in the feed
    // but were not in the recommendation block are promoted right below it
    // (AI-FEED-04). Own posts and already-applied jobs stay where they are.
    final promotedJobs = posts.where((post) {
      if (rankedIds.contains(post.id)) return false;
      if (post.type != PostType.job || post.isOwnPost) return false;
      if (post.lifecycleState != JobLifecycleState.open) return false;
      return post.applicationState != JobApplicationState.applied;
    }).toList();
    final promotedIds = promotedJobs.map((p) => p.id).toSet();
    final rest = posts
        .where((post) =>
            !rankedIds.contains(post.id) && !promotedIds.contains(post.id))
        .toList();

    return [...ranked, ...promotedJobs, ...rest];
  }

  Future<List<FeedPost>> _applyLocalState(List<FeedPost> items) async {
    Set<String> appliedJobIds = {};
    try {
      appliedJobIds = await _jobApplicationRepository.getAppliedJobPostIds();
    } catch (_) {
      appliedJobIds = {};
    }

    return items.map((post) {
      final reacted = _postRepository.isReacted(post.id) || post.userReacted;
      final following =
          _postRepository.isFollowing(post.author.id) || post.isFollowingAuthor;
      final applied = post.type == PostType.job &&
          (post.applicationState == JobApplicationState.applied ||
              appliedJobIds.contains(post.id));
      return post.copyWith(
        userReacted: reacted,
        userReaction:
            reacted ? (post.userReaction ?? PostReactionType.like) : null,
        isFollowingAuthor: following,
        applicationState:
            applied ? JobApplicationState.applied : post.applicationState,
      );
    }).toList();
  }

  void _updatePostsById(String postId, FeedPost Function(FeedPost) transform) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index >= 0) posts[index] = transform(posts[index]);
  }

  void _updatePostsByAuthor(
      String authorId, FeedPost Function(FeedPost) transform) {
    for (var i = 0; i < posts.length; i++) {
      if (posts[i].author.id == authorId) posts[i] = transform(posts[i]);
    }
  }

  Future<void> toggleReaction(String postId) async {
    await setReaction(postId, PostReactionType.like);
  }

  Future<void> setReaction(String postId, PostReactionType type) async {
    if (_mutationPosts.contains(postId)) return;
    _mutationPosts.add(postId);

    FeedPost? previous;
    _updatePostsById(postId, (post) {
      previous = post;
      final current = post.activeReaction;
      if (current == type) {
        // Same reaction again → remove.
        return post.copyWith(
          userReacted: false,
          userReaction: null,
          reactionCount: (post.reactionCount - 1).clamp(0, 999999),
        );
      }
      final wasReacted = post.userReacted;
      return post.copyWith(
        userReacted: true,
        userReaction: type,
        reactionCount: wasReacted
            ? post.reactionCount
            : (post.reactionCount + 1).clamp(0, 999999),
      );
    });

    try {
      final next = posts.firstWhereOrNull((p) => p.id == postId);
      final shouldBeReacted = next?.userReacted ?? false;
      final wasReacted = previous?.userReacted ?? false;
      if (shouldBeReacted != wasReacted) {
        await _postRepository.toggleReaction(postId);
      }
    } catch (_) {
      if (previous != null) _updatePostsById(postId, (_) => previous!);
      Get.snackbar(AppStrings.appName, 'Could not update reaction');
    } finally {
      _mutationPosts.remove(postId);
    }
  }

  Future<void> toggleFollow(String authorId) async {
    if (_mutationAuthors.contains(authorId)) return;
    _mutationAuthors.add(authorId);

    final visiblePost =
        posts.firstWhereOrNull((post) => post.author.id == authorId);
    final wasFollowing =
        visiblePost?.isFollowingAuthor ?? _postRepository.isFollowing(authorId);
    _updatePostsByAuthor(
        authorId, (post) => post.copyWith(isFollowingAuthor: !wasFollowing));

    try {
      await _postRepository.setFollow(authorId, !wasFollowing);
    } catch (_) {
      _updatePostsByAuthor(
          authorId, (post) => post.copyWith(isFollowingAuthor: wasFollowing));
      Get.snackbar(AppStrings.appName, 'Could not update follow');
    } finally {
      _mutationAuthors.remove(authorId);
    }
  }

  void openComments(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;
    Get.bottomSheet(
      CommentSheet(
        post: post,
        onCommentAdded: () {
          _updatePostsById(
              postId, (p) => p.copyWith(commentCount: p.commentCount + 1));
        },
        onCommentsRemoved: (count) {
          _updatePostsById(
            postId,
            (p) => p.copyWith(
              commentCount: (p.commentCount - count).clamp(0, 999999),
            ),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openShareSheet(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;
    Get.bottomSheet(
      ShareSheet(
        post: post,
        onShared: () {
          _updatePostsById(
              postId, (p) => p.copyWith(shareCount: p.shareCount + 1));
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openPost(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: postId)?.then((result) async {
      if (result is PostMutationResult) {
        posts.removeWhere((post) => post.id == result.postId);
        return;
      }
      if (result is FeedPost) {
        final index = posts.indexWhere((p) => p.id == result.id);
        if (index >= 0) {
          final normalized = await _applyLocalState([result]);
          posts[index] = normalized.first;
        }
      }
    });
  }

  void openCreatePost({PostType? type}) {
    Get.toNamed(AppRoutes.createPost, arguments: type)?.then((result) {
      if (result is FeedPost) insertCreatedPost(result);
    });
  }

  void editPost(FeedPost post) {
    if (!post.isOwnPost) return;
    Get.toNamed(
      AppRoutes.createPost,
      arguments: CreatePostArgs(editingPost: post),
    )?.then((result) async {
      if (result is! FeedPost) return;
      final normalized = await _applyLocalState([result]);
      final index = posts.indexWhere((item) => item.id == result.id);
      if (index >= 0) posts[index] = normalized.first;
    });
  }

  Future<void> deletePost(BuildContext context, FeedPost post) async {
    if (!post.isOwnPost) return;
    final confirmed = await showConfirmDialog(
      context: context,
      title: 'Delete post?',
      message:
          'This post and its comments will be permanently removed. This cannot be undone.',
      confirmLabel: 'Delete',
      cancelLabel: 'Keep post',
      variant: ConfirmDialogVariant.destructive,
    );
    if (confirmed != true) return;
    try {
      await _postRepository.deletePost(post.id);
      posts.removeWhere((item) => item.id == post.id);
      Get.snackbar(AppStrings.appName, 'Post deleted');
    } catch (error) {
      Get.snackbar(AppStrings.appName, error.toString());
    }
  }

  void insertCreatedPost(FeedPost post) {
    _applyLocalState([post]).then((normalized) {
      posts.removeWhere((p) => p.id == normalized.first.id);
      posts.insert(0, normalized.first);
    });
  }

  void setActiveVideo(String? postId) => activeVideoId.value = postId;

  void openAuthorProfile(String authorId) {
    openUserProfile(authorId);
  }

  void onTabSelected(int index) {
    MainTabNavigation.handle(index, currentIndex: currentTab.value);
  }

  void openJobApplication(FeedPost jobPost) {
    Get.toNamed(
      AppRoutes.applyCv,
      arguments: ApplyCvArgs(jobPostId: jobPost.id, jobPreview: jobPost),
    )?.then((result) {
      if (result is ApplyCvResult) {
        _updatePostsById(
          result.jobPostId,
          (p) => p.copyWith(applicationState: JobApplicationState.applied),
        );
      }
    });
  }

  void openJobApplicants(FeedPost jobPost) {
    Get.toNamed(
      AppRoutes.jobApplicants,
      arguments: JobApplicantsArgs(
        jobPostId: jobPost.id,
        jobTitle: jobPost.jobMeta.title,
      ),
    );
  }
}
