import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/core/utils/relative_time.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/widgets/feed_action_bar.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ProfileReelsCard extends StatelessWidget {
  const ProfileReelsCard({
    super.key,
    required this.post,
    required this.onLike,
    required this.onComment,
    required this.onShare,
  });

  final FeedPost post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    final title = post.jobMeta.title?.isNotEmpty == true
        ? post.jobMeta.title!
        : (post.content.length > 40
            ? '${post.content.substring(0, 40)}…'
            : post.content);

    return VitheyCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 8),
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => showMediaFullscreen(
              context,
              post,
              onLike: onLike,
              onComment: onComment,
              onShare: onShare,
              showShareAction: false,
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (post.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: post.thumbnailUrl!,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: context.appColors.inputFill),
                  Container(color: Colors.black.withValues(alpha: 0.25)),
                  const Center(
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white54,
                      child: VitheyIcon(
                        LucideIcons.play,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (post.content.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  RelativeTime.format(post.createdAt),
                  style: context.text.labelMedium,
                ),
              ],
            ),
          ),
          FeedActionBar(
            post: post,
            onLike: onLike,
            onComment: onComment,
            onShare: onShare,
            alignStart: true,
            showShareAction: false,
          ),
        ],
      ),
    );
  }
}
