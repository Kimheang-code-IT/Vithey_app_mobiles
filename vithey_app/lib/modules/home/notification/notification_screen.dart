import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/custom_button.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/core/widgets/vithey_search_pill.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/modules/home/notification/notification_controller.dart';
import 'package:aub_connect_app/modules/home/notification/widgets/notification_filter_bar.dart';
import 'package:aub_connect_app/modules/home/notification/widgets/notification_group_header.dart';
import 'package:aub_connect_app/modules/home/notification/widgets/notification_item.dart';
import 'package:aub_connect_app/modules/home/notification/widgets/notification_item_skeleton.dart';
import 'package:aub_connect_app/modules/home/notification/widgets/notification_list_entrance.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

class NotificationScreen extends GetView<NotificationController> {
  const NotificationScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final bottomClearance = embedded
        ? AppBottomNavigation.scrollClearance(context, extra: 20)
        : 0.0;

    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: context.appColors.bodyBackground,
        foregroundColor: context.appColors.heading,
        titleSpacing: 0,
        leading: VitheyIconButton(
          icon: LucideIcons.settings,
          tooltip: 'Settings',
          onTap: () => Get.toNamed(AppRoutes.settings),
        ),
        title: Text(
          'Notification',
          style: context.text.titleLarge?.copyWith(fontSize: 20),
        ),
        actions: [
          Obx(() {
            final searching = controller.isSearchOpen.value;
            return VitheyIconButton(
              icon: searching ? LucideIcons.x : LucideIcons.search,
              tooltip: searching ? 'Close search' : 'Search notifications',
              onTap: () {
                if (searching) {
                  controller.closeSearch();
                } else {
                  controller.openSearch();
                }
              },
            );
          }),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: context.appColors.border,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomClearance),
        child: Obx(() {
          final searching = controller.isSearchOpen.value;
          return Column(
            children: [
              if (searching) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: VitheySearchPill(
                    controller: controller.searchController,
                    hintText: 'Search notifications',
                    autofocus: true,
                    onChanged: controller.setSearchQuery,
                    onClear: () {
                      controller.searchController.clear();
                      controller.setSearchQuery('');
                    },
                  ),
                ),
              ],
              const SizedBox(height: 10),
              NotificationFilterBar(
                selected: controller.filter.value,
                onSelected: controller.selectFilter,
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildContent(context)),
            ],
          );
        }),
      ),
      bottomNavigationBar: embedded
          ? null
          : AppBottomNavigation(
              currentIndex: MainTabNavigation.notifications,
              onTap: (index) => MainTabNavigation.handle(
                index,
                currentIndex: MainTabNavigation.notifications,
              ),
            ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (controller.isLoading.value && controller.notifications.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        itemCount: 7,
        itemBuilder: (_, __) => const NotificationItemSkeleton(),
      );
    }
    if (controller.hasError.value && controller.notifications.isEmpty) {
      return AppErrorWidget(
        message: controller.errorMessage.value,
        onRetry: controller.loadNotifications,
      );
    }

    final query = controller.searchQuery.value.trim();
    final sections = controller.sections;
    final noMatches = query.isNotEmpty && sections.isEmpty;

    if (controller.notifications.isEmpty || noMatches) {
      final filter = controller.filter.value;
      return EmptyStateWidget(
        title: noMatches
            ? 'No matches'
            : switch (filter) {
                NotificationFilter.all => 'No notifications yet',
                NotificationFilter.read => 'Nothing here yet',
                NotificationFilter.unread => 'You\'re all caught up',
              },
        subtitle: noMatches
            ? 'Try a different name or keyword'
            : switch (filter) {
                NotificationFilter.all =>
                  'Your latest activity will appear here',
                NotificationFilter.read =>
                  'Read notifications will appear here',
                NotificationFilter.unread =>
                  'Unread notifications will appear here',
              },
        icon: noMatches ? LucideIcons.search : LucideIcons.bell,
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshNotifications,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          if (scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200) {
            controller.loadMore();
          }
          return false;
        },
        child: ListView(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ..._buildAnimatedSections(),
            if (controller.isLoadingMore.value)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            if (controller.paginationError.value)
              Center(
                child: CustomButton(
                  label: 'Retry',
                  onPressed: controller.loadMore,
                  variant: CustomButtonVariant.ghost,
                  icon: LucideIcons.refreshCw,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Flattens sections into headers + cards, each wrapped in a staggered
  /// entrance animation. Keys include the active filter so the animation
  /// replays on every tab switch but not on unrelated rebuilds.
  List<Widget> _buildAnimatedSections() {
    final filter = controller.filter.value;
    final query = controller.searchQuery.value;
    final direction = controller.slideDirection;
    final children = <Widget>[];
    var index = 0;

    for (final section in controller.sections) {
      children.add(
        NotificationListEntrance(
          key: ValueKey('$filter-$query-header-${section.title}'),
          index: index++,
          direction: direction,
          child: NotificationGroupHeader(title: section.title),
        ),
      );
      for (final notification in section.items) {
        children.add(
          NotificationListEntrance(
            key: ValueKey('$filter-$query-item-${notification.id}'),
            index: index++,
            direction: direction,
            child: _buildItem(notification),
          ),
        );
      }
    }
    return children;
  }

  Widget _buildItem(AppNotification notification) {
    return NotificationItem(
      notification: notification,
      onTap: () => controller.openNotification(notification.id),
      onMore: () => controller.openActionSheet(notification),
    );
  }
}
