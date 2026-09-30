import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/vithey_card.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_grid_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// LinkedIn-style content row for own-profile Reels / Posters analytics entry.
///
/// Title on the left, view count on the right — tap opens post analytics.
class ProfileContentAnalyticsTile extends StatelessWidget {
  const ProfileContentAnalyticsTile({
    super.key,
    required this.post,
    required this.onTap,
  });

  final FeedPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final thumb = post.thumbnailUrl ?? post.mediaUrl;
    final isVideo = post.type == PostType.video;

    return VitheyCard(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 5),
      bordered: true,
      elevated: false,
      borderRadius: VitheyRadii.card,
      clipBehavior: Clip.antiAlias,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(VitheyRadii.media),
              child: SizedBox(
                width: 56,
                height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (thumb != null && thumb.isNotEmpty)
                      CachedNetworkImage(
                        imageUrl: thumb,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            ColoredBox(color: colors.inputFill),
                      )
                    else
                      ColoredBox(color: colors.inputFill),
                    if (isVideo)
                      const ColoredBox(
                        color: Color(0x33000000),
                        child: Center(
                          child: VitheyIcon(
                            LucideIcons.play,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                post.displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(height: 1.3),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VitheyIcon(
                      LucideIcons.eye,
                      size: 14,
                      color: colors.muted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatReelStatCount(post.viewCount),
                      style: context.text.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colors.heading,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'views',
                  style: context.text.labelSmall,
                ),
              ],
            ),
            VitheyIcon(
              LucideIcons.chevronRight,
              size: 18,
              color: colors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
