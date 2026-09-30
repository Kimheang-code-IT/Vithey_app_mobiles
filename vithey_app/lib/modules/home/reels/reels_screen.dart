import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/empty_state_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/vithey_icon_button.dart';
import 'package:aub_connect_app/modules/home/reels/reels_controller.dart';
import 'package:aub_connect_app/modules/home/reels/widgets/reel_video_page.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class ReelsScreen extends GetView<ReelsController> {
  const ReelsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final bottomInset = embedded
        ? MediaQuery.paddingOf(context).bottom
        : 88.0 + MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBody: true,
        body: Obx(() {
          if (controller.isLoading.value && controller.posts.isEmpty) {
            return const ColoredBox(
              color: Colors.black,
              child: LoadingWidget(),
            );
          }
          if (controller.hasError.value && controller.posts.isEmpty) {
            return ColoredBox(
              color: Colors.black,
              child: AppErrorWidget(
                message: controller.errorMessage.value,
                onRetry: controller.loadReels,
              ),
            );
          }
          if (controller.posts.isEmpty) {
            return const ColoredBox(
              color: Colors.black,
              child: EmptyStateWidget(
                title: 'No reels yet',
                subtitle: 'Video posts from the community will show up here',
                icon: LucideIcons.video,
              ),
            );
          }

          final posts = controller.posts.toList();
          final current = controller.currentIndex.value;
          final muted = controller.isMuted.value;

          return Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: controller.pageController,
                scrollDirection: Axis.vertical,
                itemCount: posts.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (_, index) {
                  final post = posts[index];
                  return ReelVideoPage(
                    key: ValueKey(post.id),
                    post: post,
                    isActive: index == current,
                    muted: muted,
                    onToggleMute: controller.toggleMute,
                    onLike: () => controller.toggleLike(post.id),
                    onComment: () => controller.openComments(post.id),
                    onAuthorTap: () => controller.openAuthor(post.author.id),
                    bottomInset: bottomInset,
                  );
                },
              ),

              // Facebook/TikTok-style header overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.paddingOf(context).top,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.55),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SizedBox(
                    height: kToolbarHeight,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            'Reels',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: -0.3),
                          ),
                          const Spacer(),
                          VitheyIconButton(
                            icon: LucideIcons.search,
                            onTap: () => Get.toNamed(AppRoutes.search),
                            tooltip: 'Search',
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
        bottomNavigationBar: embedded
            ? null
            : AppBottomNavigation(
                currentIndex: MainTabNavigation.reel,
                onTap: (index) => MainTabNavigation.handle(
                  index,
                  currentIndex: MainTabNavigation.reel,
                ),
              ),
      ),
    );
  }
}
