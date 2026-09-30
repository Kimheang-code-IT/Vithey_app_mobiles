import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/modules/home/post_detail/post_detail_controller.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class CommentSection extends StatelessWidget {
  const CommentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PostDetailController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (controller.isCommentsLoading.value &&
              controller.comments.isEmpty) {
            return const Column(
                children: [ShimmerListTile(), ShimmerListTile()]);
          }
          if (controller.comments.isEmpty) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Text(
                'No comments yet. Be the first to comment.',
                style: context.text.bodySmall,
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.comments.length,
            itemBuilder: (_, index) {
              final comment = controller.comments[index];
              final isReply = comment.isReply;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  isReply ? 56 : 20,
                  6,
                  10,
                  8,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    UserAvatar(
                      name: comment.author.fullName,
                      imageUrl: comment.author.avatarUrl,
                      radius: isReply ? 15 : 18,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(10, 9, 10, 9),
                            decoration: BoxDecoration(
                              color: context.appColors.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: context.appColors.border,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comment.author.fullName,
                                  style: context.text.labelLarge
                                      ?.copyWith(fontSize: isReply ? 13 : 14),
                                ),
                                const SizedBox(height: 4),
                                _MentionText(text: comment.text),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 1, top: 5),
                            child: Wrap(
                              spacing: 12,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                _CommentAction(
                                  label: 'Like',
                                  onTap: () {},
                                ),
                                _CommentAction(
                                  label: 'Reply',
                                  onTap: () => controller.replyTo(comment),
                                ),
                                if (comment
                                    .isOwnedBy(controller.currentUserId)) ...[
                                  _CommentAction(
                                    label: 'Edit',
                                    onTap: () => controller.startEdit(comment),
                                  ),
                                  _CommentAction(
                                    label: 'Delete',
                                    color: AppColors.error,
                                    onTap: () =>
                                        controller.deleteComment(comment),
                                  ),
                                ],
                                Text(
                                  RelativeTime.format(comment.createdAt),
                                  style: context.text.bodySmall
                                      ?.copyWith(fontSize: 11.5),
                                ),
                                if (comment.isPending)
                                  Text(
                                    'Sending…',
                                    style: context.text.bodySmall
                                        ?.copyWith(fontSize: 11.5),
                                  ),
                                if (comment.isFailed)
                                  _CommentAction(
                                    label: 'Retry',
                                    color: AppColors.primary,
                                    onTap: controller.submitComment,
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ],
    );
  }
}

class _CommentAction extends StatelessWidget {
  const _CommentAction({
    required this.label,
    required this.onTap,
    this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: context.text.labelSmall?.copyWith(
            fontSize: 11.5,
            color: color ?? context.appColors.muted,
          ),
        ),
      ),
    );
  }
}

class _MentionText extends StatelessWidget {
  const _MentionText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'@\w+');
    var start = 0;
    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w600),
      ));
      start = match.end;
    }
    if (start < text.length) spans.add(TextSpan(text: text.substring(start)));

    return RichText(
        text: TextSpan(
            style: DefaultTextStyle.of(context).style, children: spans));
  }
}
