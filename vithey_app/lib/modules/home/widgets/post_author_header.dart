import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

class PostAuthorHeader extends StatelessWidget {
  const PostAuthorHeader({
    super.key,
    required this.post,
    this.trailing,
    this.onAuthorTap,
  });

  final FeedPost post;
  final Widget? trailing;
  final VoidCallback? onAuthorTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 11, 10, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onAuthorTap,
            child: UserAvatar(
              name: post.author.fullName,
              imageUrl: post.author.avatarUrl,
              radius: 18,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: GestureDetector(
              onTap: onAuthorTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall,
                  ),
                  Text(
                    RelativeTime.format(post.createdAt),
                    style: context.text.bodyMedium
                        ?.copyWith(color: context.appColors.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
