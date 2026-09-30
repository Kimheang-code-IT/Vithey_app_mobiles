import 'package:flutter/material.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/modules/profile/profile_view_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_all.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reels.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_tabs.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_cover_redesign.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';

/// Visitor profile screen (e.g. Khorn Molika viewing Heng Liza).
class ProfileViewScreen extends GetView<ProfileViewController> {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final host = controller;

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget(message: 'Loading profile...');
        }
        if (controller.hasError.value) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.refreshProfile,
          );
        }
        final profile = controller.profile.value;
        if (profile == null) {
          return const AppErrorWidget(message: 'Profile unavailable');
        }

        const tabs = <Tab>[
          Tab(text: 'All'),
          Tab(text: 'Reels'),
          Tab(text: 'Posters'),
          Tab(text: 'Jobs'),
          Tab(text: 'Applied Jobs'),
        ];

        final tabViews = <Widget>[
          ProfileAllTab(host: host),
          ProfileReelsTab(host: host),
          ProfilePostersTab(host: host),
          ProfileJobsTab(host: host),
          ProfileAppliedJobsTab(viewController: controller),
        ];

        return NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileCoverRedesign(
                    profile: profile,
                    showMenu: false,
                    showBack: true,
                    onBack: () => Get.back(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    child: Column(
                      children: [
                        Text(
                          profile.fullName,
                          style: context.text.titleLarge
                              ?.copyWith(fontSize: 20, height: 1.2),
                          textAlign: TextAlign.center,
                        ),
                        if (profile.bio != null &&
                            profile.bio!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            profile.bio!,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(
                              color: context.appColors.muted,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ProfileStats(profile: profile),
                  ProfileActionRow(
                    isOwnProfile: false,
                    isFollowing: profile.isFollowing,
                    isStudentVerified: false,
                    onFollow: controller.toggleFollow,
                    onMessage: controller.startMessage,
                    onEditProfile: () {},
                    onVerifyStudent: () {},
                    onShare: controller.shareProfile,
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                topInset: MediaQuery.paddingOf(context).top,
                tabBar: TabBar(
                  controller: controller.tabController,
                  isScrollable: true,
                  dividerColor: context.appColors.border,
                  dividerHeight: 1,
                  tabAlignment: TabAlignment.start,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(VitheyRadii.pill),
                  ),
                  indicatorPadding: const EdgeInsets.symmetric(vertical: 6),
                  splashBorderRadius: BorderRadius.circular(VitheyRadii.pill),
                  labelColor: context.scheme.onPrimary,
                  unselectedLabelColor: context.appColors.muted,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  labelStyle: context.text.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.scheme.onPrimary,
                  ),
                  unselectedLabelStyle: context.text.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                  tabs: tabs,
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: controller.tabController,
            children: tabViews,
          ),
        );
      }),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate({required this.tabBar, required this.topInset});

  final TabBar tabBar;
  final double topInset;

  @override
  double get minExtent => tabBar.preferredSize.height + topInset;

  @override
  double get maxExtent => tabBar.preferredSize.height + topInset;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: context.appColors.bodyBackground,
      elevation: overlapsContent ? 1 : 0,
      child: Column(
        children: [
          SizedBox(height: topInset),
          tabBar,
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) => true;
}
