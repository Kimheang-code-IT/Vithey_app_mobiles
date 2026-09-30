import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/icons/vithey_icons.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/theme/vithey_radii.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/data/repositories/student_verification_repository.dart';
import 'package:aub_connect_app/modules/home/shell/main_shell_screen.dart';
import 'package:aub_connect_app/modules/jobs/ai_cv/ai_cv_args.dart';
import 'package:aub_connect_app/modules/profile/profile_controller.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_all.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_cover_redesign.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_header.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_reels.dart';
import 'package:aub_connect_app/modules/profile/widgets/profile_tabs.dart';

/// Own profile (logged-in user — Khorn Molika).
class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key, this.embedded = false});

  /// When true, used inside [MainShellScreen] (shell owns the bottom bar).
  final bool embedded;

  /// Clears the floating shell bottom nav when embedded.
  static const _fabBottomClearance = 88.0;

  Future<void> _openAiCreateCv() async {
    await Get.toNamed(
      AppRoutes.applyCvTemplates,
      arguments: const AiCvArgs(returnToApply: false),
    );
  }

  bool get _shellNavVisible {
    if (!embedded || !Get.isRegistered<MainShellController>()) return true;
    return Get.find<MainShellController>().navVisible.value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Obx(() {
        if (controller.isLoading.value ||
            controller.hasError.value ||
            controller.profile.value == null) {
          return const SizedBox.shrink();
        }
        final navVisible = _shellNavVisible;
        return IgnorePointer(
          ignoring: !navVisible,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            offset: navVisible ? Offset.zero : const Offset(0, 1.6),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 180),
              opacity: navVisible ? 1 : 0,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: embedded ? _fabBottomClearance : 0,
                ),
                child: FloatingActionButton.extended(
                  onPressed: _openAiCreateCv,
                  backgroundColor: AppColors.primary,
                  foregroundColor: context.scheme.onPrimary,
                  elevation: 3,
                  icon: VitheyIcon(
                    LucideIcons.sparkles,
                    size: 20,
                    color: context.scheme.onPrimary,
                  ),
                  label: Text(
                    'AI Create CV',
                    style: context.text.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
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

        final tabs = <Tab>[
          const Tab(text: 'All'),
          const Tab(text: 'Reels'),
          const Tab(text: 'Posters'),
          const Tab(text: 'Jobs'),
          const Tab(text: 'Applied Jobs'),
        ];

        const tabViews = <Widget>[
          ProfileAllTab(),
          ProfileReelsTab(),
          ProfilePostersTab(),
          ProfileJobsTab(),
          ProfileAppliedJobsTab(),
        ];

        return NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  ProfileCoverRedesign(
                    profile: profile,
                    showMenu: true,
                    onMenuTap: () => Get.toNamed(AppRoutes.settings),
                    onEditProfile: controller.openEditProfile,
                    onVerifyStudent: controller.openVerifyStudent,
                    isStudentVerified:
                        Get.find<StudentVerificationRepository>()
                            .isVerified
                            .value,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
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
                          const SizedBox(height: 8),
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
                  const SizedBox(height: 8),
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
      bottomNavigationBar: embedded
          ? null
          : AppBottomNavigation(
              currentIndex: MainTabNavigation.profile,
              onTap: (index) => MainTabNavigation.handle(
                index,
                currentIndex: MainTabNavigation.profile,
              ),
            ),
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
