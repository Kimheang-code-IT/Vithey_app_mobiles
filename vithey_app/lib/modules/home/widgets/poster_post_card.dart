import 'package:flutter/material.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';
import 'package:aub_connect_app/modules/home/widgets/post_card.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';

class PosterPostCard extends StatelessWidget {
  const PosterPostCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
    required this.onFollow,
    required this.onOpen,
    required this.onEdit,
    required this.onDelete,
    this.onReact,
    this.onAuthorTap,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    this.showShareAction = true,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;
  final VoidCallback onFollow;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<PostReactionType>? onReact;
  final VoidCallback? onAuthorTap;
  final EdgeInsetsGeometry margin;
  final bool showShareAction;

  @override
  Widget build(BuildContext context) {
    final hasMedia = post.mediaUrl != null && post.mediaUrl!.isNotEmpty;

    return PostCard(
      post: post,
      margin: margin,
      headerTrailing: post.isOwnPost
          ? PostOwnerActions(onEdit: onEdit, onDelete: onDelete)
          : _FollowButton(post: post, onFollow: onFollow),
      body: hasMedia ? PostMediaImage(url: post.mediaUrl) : null,
      onLike: onLike,
      onReact: onReact,
      onComment: onComment,
      onShare: onShare,
      showShareAction: showShareAction,
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
          showShareAction: showShareAction,
        );
      },
      onAuthorTap: onAuthorTap,
    );
  }
}

class _FollowButton extends StatelessWidget {
  const _FollowButton({required this.post, required this.onFollow});

  final FeedPost post;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.scheme.primary,
      borderRadius: BorderRadius.circular(VitheyRadii.pill),
      child: InkWell(
        onTap: onFollow,
        borderRadius: BorderRadius.circular(VitheyRadii.pill),
        child: SizedBox(
          height: 28,
          width: post.isFollowingAuthor ? 70 : 58,
          child: Center(
            child: Text(
              post.isFollowingAuthor ? 'Following' : 'Follow',
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
