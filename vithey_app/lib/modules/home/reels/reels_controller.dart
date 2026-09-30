import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/profile/profile_navigation.dart';
import 'package:aub_connect_app/data/repositories/post_repository.dart';
import 'package:aub_connect_app/modules/home/widgets/comment_sheet.dart';

class ReelsController extends GetxController {
  ReelsController(this._postRepository);

  final PostRepository _postRepository;

  final posts = <FeedPost>[].obs;
  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;
  final currentIndex = 0.obs;
  final isMuted = false.obs;

  PageController? _pageController;
  PageController get pageController => _pageController ??= PageController();

  @override
  void onInit() {
    super.onInit();
    loadReels();
  }

  @override
  void onClose() {
    _pageController?.dispose();
    super.onClose();
  }

  Future<void> loadReels() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await _postRepository.fetchReels(page: 1, limit: 40);
      posts.assignAll(result.posts);
      if (currentIndex.value >= posts.length) {
        currentIndex.value = 0;
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshReels() => loadReels();

  void onPageChanged(int index) {
    currentIndex.value = index;
  }

  void toggleMute() {
    isMuted.toggle();
  }

  void toggleLike(String postId) {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;
    final post = posts[index];
    final liked = !post.userReacted;
    posts[index] = post.copyWith(
      userReacted: liked,
      reactionCount: (post.reactionCount + (liked ? 1 : -1)).clamp(0, 1 << 30),
    );
  }

  void openComments(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;
    Get.bottomSheet(
      CommentSheet(
        post: post,
        onCommentAdded: () {
          final i = posts.indexWhere((p) => p.id == postId);
          if (i < 0) return;
          posts[i] = posts[i].copyWith(
            commentCount: posts[i].commentCount + 1,
          );
        },
        onCommentsRemoved: (count) {
          final i = posts.indexWhere((p) => p.id == postId);
          if (i < 0) return;
          posts[i] = posts[i].copyWith(
            commentCount: (posts[i].commentCount - count).clamp(0, 999999),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void openAuthor(String authorId) => openUserProfile(authorId);

  void openPost(String postId) {
    Get.toNamed(AppRoutes.postDetail, arguments: postId);
  }
}
