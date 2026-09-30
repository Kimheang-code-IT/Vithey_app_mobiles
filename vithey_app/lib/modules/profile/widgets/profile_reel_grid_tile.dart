import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Compact count like Facebook Reels (1.2K, 220K).
String formatReelStatCount(int count) {
  if (count >= 1000000) {
    final m = count / 1000000;
    return m >= 10 ? '${m.toStringAsFixed(0)}M' : '${m.toStringAsFixed(1)}M';
  }
  if (count >= 1000) {
    final k = count / 1000;
    return k >= 10 ? '${k.toStringAsFixed(0)}K' : '${k.toStringAsFixed(1)}K';
  }
  return '$count';
}

/// Portrait thumbnail tile for the Reels grid.
class ProfileReelGridTile extends StatelessWidget {
  const ProfileReelGridTile({
    super.key,
    required this.post,
    required this.onTap,
  });

  final FeedPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    // Prefer real view counts; fall back to reactions until API fills views.
    final stat = post.viewCount > 0
        ? post.viewCount
        : (post.reactionCount > 0 ? post.reactionCount : post.commentCount);

    // GenZ rounded reel tile (r16) with soft surface + border.
    return Material(
      color: colors.inputFill,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(VitheyRadii.card),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (post.thumbnailUrl != null && post.thumbnailUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: post.thumbnailUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => ColoredBox(color: colors.inputFill),
              )
            else if (post.mediaUrl != null && post.mediaUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: post.mediaUrl!,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => ColoredBox(color: colors.inputFill),
              )
            else
              ColoredBox(
                color: colors.inputFill,
                child: VitheyIcon(
                  LucideIcons.video,
                  color: colors.muted,
                  size: 32,
                ),
              ),
            // Soft bottom scrim for the stat row.
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color(0x99000000),
                    ],
                  ),
                ),
                child: SizedBox(height: 40),
              ),
            ),
            Positioned(
              left: 6,
              bottom: 6,
              right: 6,
              child: Row(
                children: [
                  const VitheyIcon(
                    LucideIcons.eye,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      formatReelStatCount(stat),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
