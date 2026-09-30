import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/user_avatar.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/home/widgets/home_app_bar.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
/// One media circle in the home header (Telegram-style stories strip).
class HomeMediaItem {
  const HomeMediaItem({
    required this.id,
    required this.label,
    this.imageUrl,
    this.postId,
    this.authorId,
    this.isOwn = false,
    this.hasUnseen = true,
  });

  final String id;
  final String label;
  final String? imageUrl;
  final String? postId;
  final String? authorId;
  final bool isOwn;
  final bool hasUnseen;
}

/// Pinned header: expanded shows media row; collapsed shows overlapping avatars.
class HomeFlexibleHeader extends StatelessWidget {
  const HomeFlexibleHeader({
    super.key,
    required this.items,
    required this.onOpenOwnMedia,
    required this.onOpenItem,
  });

  final List<HomeMediaItem> items;
  final VoidCallback onOpenOwnMedia;
  final ValueChanged<HomeMediaItem> onOpenItem;

  static const double toolbarHeight = kToolbarHeight;
  static const double mediaRowHeight = 100;
  static const double maxHeight = toolbarHeight + mediaRowHeight;
  static const double minHeight = toolbarHeight;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: _HomeFlexibleHeaderDelegate(
        items: items,
        onOpenOwnMedia: onOpenOwnMedia,
        onOpenItem: onOpenItem,
      ),
    );
  }
}

class _HomeFlexibleHeaderDelegate extends SliverPersistentHeaderDelegate {
  _HomeFlexibleHeaderDelegate({
    required this.items,
    required this.onOpenOwnMedia,
    required this.onOpenItem,
  });

  final List<HomeMediaItem> items;
  final VoidCallback onOpenOwnMedia;
  final ValueChanged<HomeMediaItem> onOpenItem;

  @override
  double get maxExtent => HomeFlexibleHeader.maxHeight;

  @override
  double get minExtent => HomeFlexibleHeader.minHeight;

  @override
  bool shouldRebuild(covariant _HomeFlexibleHeaderDelegate oldDelegate) {
    return oldDelegate.items != items;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // Pinned headers keep growing shrinkOffset past (max-min); always clamp.
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final t = (shrinkOffset / range).clamp(0.0, 1.0);
    final expandT = 1.0 - t;
    final colors = context.appColors;
    final title = AppStrings.appName.split(' ').first;
    final collapsedItems = items.where((e) => !e.isOwn).take(3).toList();
    final stackItems =
        collapsedItems.isNotEmpty ? collapsedItems : items.take(3).toList();

    return Material(
      color: colors.cardSurface,
      elevation: overlapsContent || t > 0.2 ? 0.5 : 0,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.maxHeight;
          // How much of the media strip is still visible under current height.
          final mediaVisible = (height - minExtent)
              .clamp(0.0, HomeFlexibleHeader.mediaRowHeight);

          return ClipRect(
            child: SizedBox(
              width: constraints.maxWidth,
              height: height,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: minExtent,
                    child: _Toolbar(
                      title: title,
                      expandT: expandT,
                      t: t,
                      stackItems: stackItems,
                      onOpenOwnMedia: onOpenOwnMedia,
                      onOpenItem: onOpenItem,
                    ),
                  ),
                  if (mediaVisible > 0.5)
                    Positioned(
                      top: minExtent,
                      left: 0,
                      right: 0,
                      height: mediaVisible,
                      child: ClipRect(
                        child: OverflowBox(
                          maxHeight: HomeFlexibleHeader.mediaRowHeight,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: HomeFlexibleHeader.mediaRowHeight,
                            child: Opacity(
                              opacity: (mediaVisible /
                                      HomeFlexibleHeader.mediaRowHeight)
                                  .clamp(0.0, 1.0),
                              child: _MediaStoriesRow(
                                items: items,
                                onOpenOwnMedia: onOpenOwnMedia,
                                onOpenItem: onOpenItem,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: colors.border.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({
    required this.title,
    required this.expandT,
    required this.t,
    required this.stackItems,
    required this.onOpenOwnMedia,
    required this.onOpenItem,
  });

  final String title;
  final double expandT;
  final double t;
  final List<HomeMediaItem> stackItems;
  final VoidCallback onOpenOwnMedia;
  final ValueChanged<HomeMediaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Opacity(
                  opacity: expandT,
                  child: IgnorePointer(
                    ignoring: t > 0.5,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        title,
                        style: context.text.headlineSmall?.copyWith(fontSize: 26, fontWeight: FontWeight.w800, color: colors.heading, letterSpacing: -0.3),
                      ),
                    ),
                  ),
                ),
                Opacity(
                  opacity: t,
                  child: IgnorePointer(
                    ignoring: t < 0.5,
                    child: Row(
                      children: [
                        if (stackItems.isNotEmpty) ...[
                          _OverlappingMediaStack(
                            items: stackItems,
                            onTap: () {
                              final first = stackItems.first;
                              if (first.isOwn) {
                                onOpenOwnMedia();
                              } else {
                                onOpenItem(first);
                              }
                            },
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleLarge,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          HomeAppBarAction(
            icon: const VitheyIcon(LucideIcons.search),
            onPressed: () => Get.toNamed(AppRoutes.search),
            tooltip: 'Search',
          ),
          HomeAppBarAction(
            icon: const VitheyIcon(LucideIcons.mapPinned),
            onPressed: () => Get.toNamed(AppRoutes.map),
            tooltip: 'Map',
          ),
          const HomeChatAppBarAction(),
          const HomeAppBarAction(
            icon: VitheyIcon(LucideIcons.wallet),
            onPressed: FinanceNavigation.openFinanceEntry,
            tooltip: 'Finance',
          ),
        ],
      ),
    );
  }
}

class _OverlappingMediaStack extends StatelessWidget {
  const _OverlappingMediaStack({
    required this.items,
    required this.onTap,
  });

  final List<HomeMediaItem> items;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const size = 32.0;
    const overlap = 12.0;
    final width = size + (items.length - 1) * (size - overlap);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: width,
        height: size,
        child: Stack(
          children: [
            for (var i = 0; i < items.length; i++)
              Positioned(
                left: i * (size - overlap),
                child: _MediaRingAvatar(
                  item: items[i],
                  size: size,
                  ringWidth: 2,
                  showAddBadge: false,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaStoriesRow extends StatelessWidget {
  const _MediaStoriesRow({
    required this.items,
    required this.onOpenOwnMedia,
    required this.onOpenItem,
  });

  final List<HomeMediaItem> items;
  final VoidCallback onOpenOwnMedia;
  final ValueChanged<HomeMediaItem> onOpenItem;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => notification.depth == 0,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _MediaStoryChip(
            item: item,
            onTap: () {
              if (item.isOwn) {
                onOpenOwnMedia();
              } else {
                onOpenItem(item);
              }
            },
          );
        },
      ),
    );
  }
}

class _MediaStoryChip extends StatelessWidget {
  const _MediaStoryChip({
    required this.item,
    required this.onTap,
  });

  final HomeMediaItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _MediaRingAvatar(
              item: item,
              size: 58,
              ringWidth: 2.5,
              showAddBadge: item.isOwn,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: context.text.labelMedium?.copyWith(
                fontSize: 12,
                height: 1.1,
                color: context.appColors.heading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaRingAvatar extends StatelessWidget {
  const _MediaRingAvatar({
    required this.item,
    required this.size,
    required this.ringWidth,
    required this.showAddBadge,
  });

  final HomeMediaItem item;
  final double size;
  final double ringWidth;
  final bool showAddBadge;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final showRing = item.hasUnseen && !item.isOwn;
    final inset = showRing ? ringWidth + 2 : 3.0;
    final avatarRadius = ((size / 2) - inset).clamp(8.0, size / 2);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            padding: EdgeInsets.all(showRing ? ringWidth : 0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: showRing
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.secondaryLight,
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                    )
                  : null,
              border: showRing
                  ? null
                  : Border.all(
                      color: colors.border.withValues(alpha: 0.8),
                      width: 1,
                    ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.cardSurface,
              ),
              padding: const EdgeInsets.all(2),
              child: UserAvatar(
                name: item.label,
                imageUrl: item.imageUrl,
                radius: avatarRadius,
              ),
            ),
          ),
          if (showAddBadge)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.cardSurface, width: 2),
                ),
                child: const VitheyIcon(LucideIcons.plus, size: 12, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
