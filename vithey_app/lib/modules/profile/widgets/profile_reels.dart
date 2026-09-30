import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/create_post/models/create_post_args.dart';
import 'package:aub_connect_app/modules/home/widgets/media_fullscreen_viewer.dart';
import 'package:aub_connect_app/modules/profile/profile_tabs_host.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_create_tile.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reel_grid_tile.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_content_analytics_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// Profile → Reels: Facebook-style 3-column grid + filter chips + Create tile.
class ProfileReelsTab extends StatefulWidget {
  const ProfileReelsTab({super.key, this.host});

  final ProfileTabsHost? host;

  @override
  State<ProfileReelsTab> createState() => _ProfileReelsTabState();
}

enum _ReelFilter { all, liked, shared, popular }

class _ProfileReelsTabState extends State<ProfileReelsTab> {
  _ReelFilter _filter = _ReelFilter.all;

  List<FeedPost> _applyFilter(List<FeedPost> posts) {
    switch (_filter) {
      case _ReelFilter.all:
        return posts;
      case _ReelFilter.liked:
        return posts.where((p) => p.userReacted || p.reactionCount > 0).toList();
      case _ReelFilter.shared:
        return posts.where((p) => p.shareCount > 0).toList();
      case _ReelFilter.popular:
        final sorted = List<FeedPost>.from(posts)
          ..sort((a, b) => b.reactionCount.compareTo(a.reactionCount));
        return sorted.where((p) => p.reactionCount > 0).toList();
    }
  }

  void _openCreateReel() {
    Get.toNamed(
      AppRoutes.createPost,
      arguments: const CreatePostArgs(initialType: PostType.video),
    );
  }

  void _openReel(BuildContext context, FeedPost post, ProfileTabsHost host) {
    showMediaFullscreen(
      context,
      post,
      onLike: () {},
      onComment: () => host.openPost(post.id),
      onShare: () {},
      showShareAction: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final host = resolveProfileTabsHost(widget.host);
    final colors = context.appColors;

    return Obx(() {
      if (host.tabLoading[PostType.video]!.value &&
          host.tabPosts[PostType.video]!.isEmpty) {
        return const LoadingWidget();
      }

      final allPosts = host.tabPosts[PostType.video]!.toList();
      final posts = _applyFilter(allPosts);
      final showCreate = host.isOwnProfile;
      final emptyAfterFilter = posts.isEmpty && allPosts.isNotEmpty;

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: _ReelFilterChips(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
            ),
          ),
          if (allPosts.isEmpty && !showCreate)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                title: 'Nothing here yet',
                subtitle: 'No Reels yet',
                icon: LucideIcons.video,
              ),
            )
          else if (allPosts.isEmpty && showCreate)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildListDelegate([
                  ProfileReelCreateTile(onTap: _openCreateReel),
                ]),
              ),
            )
          else if (emptyAfterFilter)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateWidget(
                title: 'No matching reels',
                subtitle: 'Try another filter',
                icon: LucideIcons.listX,
              ),
            )
          else if (showCreate)
            // Own profile: LinkedIn-style title (left) + views (right) → analytics.
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          height: 120,
                          child: ProfileReelCreateTile(onTap: _openCreateReel),
                        ),
                      );
                    }
                    final post = posts[index - 1];
                    return ProfileContentAnalyticsTile(
                      post: post,
                      onTap: () => host.openPostAnalytics(post),
                    );
                  },
                  childCount: posts.length + 1,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return ProfileReelGridTile(
                      post: post,
                      onTap: () => _openReel(context, post, host),
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            ),
          // Thin divider color under grid feels like FB gaps.
          SliverToBoxAdapter(
            child: ColoredBox(
              color: colors.bodyBackground,
              child: const SizedBox(height: 0),
            ),
          ),
        ],
      );
    });
  }
}

class _ReelFilterChips extends StatelessWidget {
  const _ReelFilterChips({
    required this.selected,
    required this.onSelected,
  });

  final _ReelFilter selected;
  final ValueChanged<_ReelFilter> onSelected;

  static const _items = <(_ReelFilter, String, IconData)>[
    (_ReelFilter.all, 'All', LucideIcons.layoutGrid),
    (_ReelFilter.liked, 'Liked', LucideIcons.thumbsUp),
    (_ReelFilter.shared, 'Shared', LucideIcons.share2),
    (_ReelFilter.popular, 'Popular', LucideIcons.eye),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    // VitheyFilterChips chrome: solid teal selected pill (r24, 48 tap).
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (id, label, icon) = _items[index];
          final isSelected = selected == id;
          final bg = isSelected ? AppColors.primary : colors.cardSurface;
          final fg = isSelected ? context.scheme.onPrimary : colors.heading;
          final border = isSelected ? AppColors.primary : colors.border;

          return Material(
            color: bg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(VitheyRadii.pill),
              side: BorderSide(color: border),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(id),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    VitheyIcon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: context.text.labelLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: fg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
