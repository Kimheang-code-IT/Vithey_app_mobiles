import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';

class JobPosterCard extends StatelessWidget {
  const JobPosterCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onApply,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    this.onViewApplicants,
    this.onAuthorTap,
    this.onFollow,
    this.onReact,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onApply;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewApplicants;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onFollow;
  final ValueChanged<PostReactionType>? onReact;

  @override
  Widget build(BuildContext context) {
    final hasMedia = post.mediaUrl != null && post.mediaUrl!.isNotEmpty;

    return PostCard(
      post: post,
      headerTrailing: post.isOwnPost
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _JobActionButton(
                  post: post,
                  onApply: onApply,
                  onViewApplicants: onViewApplicants,
                ),
                PostOwnerActions(onEdit: onEdit, onDelete: onDelete),
              ],
            )
          : _JobActionButton(
              post: post,
              onApply: onApply,
              onViewApplicants: onViewApplicants,
            ),
      caption: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.jobMeta.title?.isNotEmpty == true) ...[
              Text(
                post.jobMeta.title!,
                style: context.text.titleSmall,
              ),
              const SizedBox(height: 4),
            ],
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: context.text.bodyMedium?.copyWith(
                  color: context.appColors.muted,
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
      body: hasMedia ? PostMediaImage(url: post.mediaUrl) : null,
      onLike: onLike,
      onReact: onReact,
      onComment: onComment,
      onShare: onShare,
      onBodyTap: () {
        if (!hasMedia) {
          onOpen();
          return;
        }
        showMediaFullscreen(
          context,
          post,
          onLike: onLike,
          onComment: onComment,
          onShare: onShare,
          onFollow: onFollow,
          onAuthorTap: onAuthorTap,
        );
      },
      onAuthorTap: onAuthorTap,
    );
  }
}

class _JobActionButton extends StatelessWidget {
  const _JobActionButton({
    required this.post,
    required this.onApply,
    this.onViewApplicants,
  });

  final FeedPost post;
  final VoidCallback onApply;
  final VoidCallback? onViewApplicants;

  @override
  Widget build(BuildContext context) {
    if (post.isOwnPost) {
      return VitheyTextLink(
        label: 'Applicants (${post.applicantCount})',
        onPressed: onViewApplicants,
        fontSize: 10.5,
      );
    }

    switch (post.applicationState) {
      case JobApplicationState.applied:
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Text('Applied',
              style: context.text.labelLarge
                  ?.copyWith(color: context.appColors.muted)),
        );
      case JobApplicationState.checking:
        return const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2)),
        );
      case JobApplicationState.notApplied:
        if (post.lifecycleState != JobLifecycleState.open) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Text('Closed',
                style: TextStyle(color: context.appColors.muted)),
          );
        }
        return Material(
          color: context.scheme.primary,
          borderRadius: BorderRadius.circular(VitheyRadii.pill),
          child: InkWell(
            onTap: onApply,
            borderRadius: BorderRadius.circular(VitheyRadii.pill),
            child: SizedBox(
              width: 58,
              height: 28,
              child: Center(
                child: Text(
                  'Apply',
                  style: context.text.labelLarge?.copyWith(
                    fontSize: 12,
                    color: context.scheme.onPrimary,
                  ),
                ),
              ),
            ),
          ),
        );
    }
  }
}
