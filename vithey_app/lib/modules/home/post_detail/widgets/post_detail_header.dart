import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/modules/home/widgets/post_owner_actions.dart';

class PostDetailHeader extends StatelessWidget {
  const PostDetailHeader({
    super.key,
    required this.post,
    required this.onFollow,
    required this.onEdit,
    required this.onDelete,
  });

  final FeedPost post;
  final VoidCallback onFollow;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        UserAvatar(
          name: post.author.fullName,
          imageUrl: post.author.avatarUrl,
          radius: 20,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.author.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(fontSize: 14.5),
              ),
              const SizedBox(height: 2),
              Text(
                'Public  ·  ${RelativeTime.format(post.createdAt)}',
                style: context.text.bodySmall?.copyWith(fontSize: 11.5),
              ),
            ],
          ),
        ),
        if (post.isOwnPost)
          PostOwnerActions(onEdit: onEdit, onDelete: onDelete)
        else if (post.type != PostType.job) ...[
          const SizedBox(width: 8),
          Material(
            color: context.scheme.primary,
            borderRadius: BorderRadius.circular(VitheyRadii.pill),
            child: InkWell(
              onTap: onFollow,
              borderRadius: BorderRadius.circular(VitheyRadii.pill),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
        ],
      ],
    );
  }
}
