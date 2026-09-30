import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_grid_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// LinkedIn-style insights row: title on the left, views on the right.
///
/// Shown on own-profile posters / reels. Tap opens the post analytics screen.
class ProfilePostInsightsBar extends StatelessWidget {
  const ProfilePostInsightsBar({
    super.key,
    required this.post,
    required this.onTap,
  });

  final FeedPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Material(
      color: colors.inputFill,
      borderRadius: BorderRadius.circular(VitheyRadii.field),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  post.displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600, color: colors.heading),
                ),
              ),
              const SizedBox(width: 10),
              VitheyIcon(
                LucideIcons.eye,
                size: 16,
                color: colors.muted,
              ),
              const SizedBox(width: 4),
              Text(
                '${formatReelStatCount(post.viewCount)} views',
                style: context.text.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.heading,
                ),
              ),
              const SizedBox(width: 2),
              VitheyIcon(
                LucideIcons.chevronRight,
                size: 18,
                color: colors.muted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
