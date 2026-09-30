import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/job_poster_card.dart';
import 'package:aub_connect_app/modules/home/widgets/poster_post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/video_post_card.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class MixedPostFeed extends StatelessWidget {
  const MixedPostFeed({super.key, this.topSlivers = const []});

  /// Pinned / leading slivers above the feed (flexible header, composer, …).
  final List<Widget> topSlivers;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();

    return Obx(() {
      return RefreshIndicator(
        onRefresh: controller.refreshFeed,
        edgeOffset: topSlivers.isEmpty ? 0 : 40,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            ...topSlivers,
            ..._bodySlivers(context, controller),
          ],
        ),
      );
    });
  }

  List<Widget> _bodySlivers(BuildContext context, HomeController controller) {
    if (controller.isInitialLoading.value) {
      return [
        SliverPadding(
          padding: EdgeInsets.only(
            top: 5,
            bottom: AppBottomNavigation.scrollClearance(context),
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, __) => const _FeedCardSkeleton(),
              childCount: 3,
            ),
          ),
        ),
      ];
    }

    if (controller.hasError.value && controller.posts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.retryFeed,
          ),
        ),
      ];
    }

    if (controller.posts.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyStateWidget(
            title: 'Nothing here yet',
            subtitle: 'Follow people or create your first post',
            actionLabel: 'Create Post',
            onAction: () => controller.openCreatePost(),
          ),
        ),
      ];
    }

    return [
      ContentedSliverList(controller: controller),
    ];
  }
}

class ContentedSliverList extends StatelessWidget {
  const ContentedSliverList({super.key, required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.only(
        top: 5,
        bottom: AppBottomNavigation.scrollClearance(context),
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == controller.posts.length) {
              if (controller.isLoadingMore.value) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              if (controller.paginationError.value) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: CustomButton(
                      label: 'Retry',
                      onPressed: controller.loadMore,
                      variant: CustomButtonVariant.ghost,
                      icon: LucideIcons.refreshCw,
                    ),
                  ),
                );
              }
              if (controller.hasMore.value) {
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => controller.loadMore());
              }
              return const SizedBox.shrink();
            }

            final post = controller.posts[index];
            return _FeedPostItem(
              key: ValueKey(post.id),
              post: post,
              controller: controller,
            );
          },
          childCount: controller.posts.length + 1,
        ),
      ),
    );
  }
}

class _FeedPostItem extends StatelessWidget {
  const _FeedPostItem({
    super.key,
    required this.post,
    required this.controller,
  });

  final FeedPost post;
  final HomeController controller;

  @override
  Widget build(BuildContext context) => _buildCard(context);

  Widget _buildCard(BuildContext context) {
    final common = (
      onLike: () => controller.toggleReaction(post.id),
      onReact: (PostReactionType type) => controller.setReaction(post.id, type),
      onComment: () => controller.openComments(post.id),
      onShare: () => controller.openShareSheet(post.id),
      onOpen: () => controller.openPost(post.id),
      onAuthorTap: () => controller.openAuthorProfile(post.author.id),
    );

    switch (post.type) {
      case PostType.poster:
        return PosterPostCard(
          post: post,
          onLike: common.onLike,
          onReact: common.onReact,
          onComment: common.onComment,
          onShare: common.onShare,
          onFollow: () => controller.toggleFollow(post.author.id),
          onOpen: common.onOpen,
          onAuthorTap: common.onAuthorTap,
          onEdit: () => controller.editPost(post),
          onDelete: () => controller.deletePost(context, post),
        );
      case PostType.video:
        return VideoPostCard(
          post: post,
          onLike: common.onLike,
          onReact: common.onReact,
          onComment: common.onComment,
          onShare: common.onShare,
          onFollow: () => controller.toggleFollow(post.author.id),
          onOpen: common.onOpen,
          onAuthorTap: common.onAuthorTap,
          onEdit: () => controller.editPost(post),
          onDelete: () => controller.deletePost(context, post),
        );
      case PostType.job:
        return JobPosterCard(
          post: post,
          onLike: common.onLike,
          onReact: common.onReact,
          onComment: common.onComment,
          onShare: common.onShare,
          onApply: () => controller.openJobApplication(post),
          onViewApplicants: () => controller.openJobApplicants(post),
          onOpen: common.onOpen,
          onAuthorTap: common.onAuthorTap,
          onFollow: () => controller.toggleFollow(post.author.id),
          onEdit: () => controller.editPost(post),
          onDelete: () => controller.deletePost(context, post),
        );
    }
  }
}

class _FeedCardSkeleton extends StatelessWidget {
  const _FeedCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        border: Border.all(color: context.appColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: context.appColors.inputFill,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SkeletonLine(
                        width: 110,
                        color: context.appColors.inputFill,
                      ),
                      const SizedBox(height: 6),
                      _SkeletonLine(
                        width: 54,
                        color: context.appColors.inputFill,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 210,
            color: context.appColors.inputFill,
          ),
          const SizedBox(height: 42),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({required this.width, required this.color});

  final double width;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 9,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}
