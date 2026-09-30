import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/post_detail/post_detail_controller.dart';
import 'package:aub_connect_app/modules/home/post_detail/widgets/comment_section.dart';
import 'package:aub_connect_app/modules/home/post_detail/widgets/mention_user_box.dart';
import 'package:aub_connect_app/modules/home/post_detail/widgets/post_detail_header.dart';
import 'package:aub_connect_app/modules/home/post_detail/widgets/post_detail_media.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class PostDetailScreen extends GetView<PostDetailController> {
  const PostDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Get.back(result: controller.post.value);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: context.appColors.cardSurface,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 8,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: context.appColors.cardSurface,
          surfaceTintColor: Colors.transparent,
          title: Text('Back', style: context.text.titleLarge),
          leading: VitheyIconButton(
            icon: LucideIcons.arrowLeft,
            variant: VitheyIconButtonVariant.neutral,
            tooltip: 'Back',
            onTap: () => Get.back(result: controller.post.value),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, color: context.appColors.border),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const LoadingWidget(message: 'Loading post...');
          }
          if (controller.hasError.value) {
            return AppErrorWidget(
              message: controller.errorMessage.value,
              onRetry: controller.loadPost,
            );
          }

          final post = controller.post.value;
          if (post == null) {
            return const AppErrorWidget(message: 'Post unavailable');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PostDetailCard(
                  post: post,
                  onFollow: controller.toggleFollow,
                  onApply: controller.applyJob,
                  onEdit: controller.editPost,
                  onDelete: () => controller.deletePost(context),
                ),
                _DetailEngagementBar(
                  post: post,
                  onReact: controller.toggleLike,
                  onComment: () => controller.commentFocus.requestFocus(),
                ),
                const CommentSection(),
              ],
            ),
          );
        }),
        bottomNavigationBar: Obx(() {
          if (controller.isLoading.value ||
              controller.hasError.value ||
              controller.post.value == null) {
            return const SizedBox.shrink();
          }
          return const _CommentComposer();
        }),
      ),
    );
  }
}

class _PostDetailCard extends StatelessWidget {
  const _PostDetailCard({
    required this.post,
    required this.onFollow,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  final FeedPost post;
  final VoidCallback onFollow;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final hasMedia = post.mediaUrl?.isNotEmpty == true ||
        post.thumbnailUrl?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        border: Border.all(
          color: context.appColors.border.withValues(alpha: 0.8),
        ),
        borderRadius: BorderRadius.circular(VitheyRadii.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PostDetailHeader(
            post: post,
            onFollow: onFollow,
            onEdit: onEdit,
            onDelete: onDelete,
          ),
          if (post.content.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              post.content,
              style: context.text.bodySmall?.copyWith(
                color: context.appColors.heading,
                fontSize: 13.5,
                height: 1.28,
              ),
            ),
          ],
          if (hasMedia) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(VitheyRadii.media),
              child: PostDetailMedia(post: post),
            ),
          ],
          if (post.type == PostType.job)
            _JobDetailBlock(post: post, onApply: onApply),
        ],
      ),
    );
  }
}

class _DetailEngagementBar extends StatelessWidget {
  const _DetailEngagementBar({
    required this.post,
    required this.onReact,
    required this.onComment,
  });

  final FeedPost post;
  final VoidCallback onReact;
  final VoidCallback onComment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
      child: Row(
        children: [
          _DetailAction(
            icon: post.userReacted
                ? LucideIcons.heart
                : LucideIcons.heart,
            count: post.reactionCount,
            color: post.userReacted
                ? context.scheme.primary
                : context.appColors.muted,
            onTap: onReact,
          ),
          _DetailAction(
            icon: LucideIcons.messageCircle,
            count: post.commentCount,
            onTap: onComment,
          ),
          _DetailAction(
            icon: LucideIcons.bookmark,
            count: post.shareCount,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _DetailAction extends StatelessWidget {
  const _DetailAction({
    required this.icon,
    required this.count,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? context.appColors.muted;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 52, minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            VitheyIcon(icon, size: 20, color: foreground),
            const SizedBox(width: 5),
            Text(
              '$count',
              style: context.text.bodyMedium
                  ?.copyWith(color: foreground, fontSize: 12),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _CommentComposer extends StatelessWidget {
  const _CommentComposer();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailController>();
    return Container(
      decoration: BoxDecoration(
        color: context.appColors.cardSurface,
        border: Border(
          top: BorderSide(
            color: context.appColors.border.withValues(alpha: 0.7),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: context.appColors.subtleShadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (!controller.showMentions.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: MentionUserBox(
                    users: controller.filteredMentionUsers,
                    onSelect: controller.mentionUser,
                  ),
                );
              }),
              Obx(() {
                final editing = controller.editingComment.value;
                final target = controller.replyTarget.value;
                if (editing == null && target == null) {
                  return const SizedBox.shrink();
                }
                final label = editing != null
                    ? 'Editing comment'
                    : 'Replying to ${target!.author.fullName}';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: context.text.labelMedium?.copyWith(fontSize: 12.5),
                        ),
                      ),
                      VitheyTextLink(
                        label: 'Cancel',
                        onPressed: editing != null
                            ? controller.cancelEdit
                            : controller.cancelReply,
                        color: context.appColors.muted,
                        fontSize: 12.5,
                      ),
                    ],
                  ),
                );
              }),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<TextEditingValue>(
                      valueListenable: controller.commentController,
                      builder: (context, value, _) {
                        return Obx(() {
                          final canSend = value.text.trim().isNotEmpty &&
                              !controller.isSending.value;
                          final colors = context.appColors;
                          return Container(
                            decoration: BoxDecoration(
                              color: colors.inputFill,
                              borderRadius:
                                  BorderRadius.circular(VitheyRadii.pill),
                              border: Border.all(
                                color: colors.border.withValues(alpha: 0.6),
                              ),
                            ),
                            padding: const EdgeInsets.only(left: 12, right: 2),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      minHeight: 36,
                                      maxHeight: 90,
                                    ),
                                    child: TextField(
                                      controller: controller.commentController,
                                      focusNode: controller.commentFocus,
                                      minLines: 1,
                                      maxLines: 3,
                                      textInputAction: TextInputAction.send,
                                      onSubmitted: (_) =>
                                          controller.submitComment(),
                                      cursorColor: AppColors.primary,
                                      style: context.text.bodyMedium
                                          ?.copyWith(height: 1.3),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        hintText: 'Amazing!',
                                        hintStyle: context.text.bodyMedium
                                            ?.copyWith(color: colors.muted),
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          vertical: 8,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 36,
                                  height: 36,
                                  child: IconButton(
                                    tooltip:
                                        controller.editingComment.value != null
                                            ? 'Save comment'
                                            : 'Send comment',
                                    onPressed: canSend
                                        ? controller.submitComment
                                        : null,
                                    padding: EdgeInsets.zero,
                                    icon: controller.isSending.value
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          )
                                        : VitheyIcon(
                                            LucideIcons.send,
                                            size: 18,
                                            color: canSend
                                                ? AppColors.primary
                                                : colors.muted
                                                    .withValues(alpha: 0.45),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JobDetailBlock extends StatelessWidget {
  const _JobDetailBlock({required this.post, required this.onApply});

  final FeedPost post;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final meta = post.jobMeta;
    final canApply = !post.isOwnPost &&
        post.lifecycleState == JobLifecycleState.open &&
        post.applicationState == JobApplicationState.notApplied;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (meta.title != null)
            Text(meta.title!,
                style: context.text.titleLarge),
          if (meta.description != null) ...[
            const SizedBox(height: 8),
            Text(meta.description!,
                style: TextStyle(color: context.appColors.muted)),
          ],
          if (meta.requirement != null) ...[
            const SizedBox(height: 8),
            Text('Requirements: ${meta.requirement}'),
          ],
          const SizedBox(height: 16),
          if (post.applicationState == JobApplicationState.applied)
            Text('Applied',
                style: context.text.labelLarge
                    ?.copyWith(color: AppColors.success))
          else if (canApply)
            CustomButton(
                label: 'Apply CV',
                icon: LucideIcons.fileText,
                onPressed: onApply)
          else if (!post.isOwnPost)
            Text('Applications closed',
                style: TextStyle(color: context.appColors.muted)),
        ],
      ),
    );
  }
}
