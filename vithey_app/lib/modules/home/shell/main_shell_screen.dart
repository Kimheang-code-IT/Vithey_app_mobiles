import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';
import 'package:aub_connect_app/modules/home/home_binding.dart';
import 'package:aub_connect_app/modules/home/home_screen.dart';
import 'package:aub_connect_app/modules/home/notification/notification_binding.dart';
import 'package:aub_connect_app/modules/home/notification/notification_screen.dart';
import 'package:aub_connect_app/modules/profile/profile_binding.dart';
import 'package:aub_connect_app/modules/profile/profile_screen.dart';
import 'package:aub_connect_app/modules/home/reels/reels_binding.dart';
import 'package:aub_connect_app/modules/home/reels/reels_screen.dart';

/// Persistent main tabs host. Tab changes animate the page content only —
/// the bottom bar stays put (no GetX route push transitions).
/// Chatbot is opened as a full-screen route (no bottom bar).
class MainShellController extends GetxController {
  final currentIndex = MainTabNavigation.home.obs;
  final navVisible = true.obs;

  late final PageController pageController;

  static const _hideThreshold = 6.0;

  @override
  void onInit() {
    super.onInit();
    final initial = _initialIndex();
    currentIndex.value = initial;
    pageController = PageController(initialPage: _pageForTab(initial));
  }

  int _initialIndex() {
    final args = Get.arguments;
    if (args is int &&
        args >= MainTabNavigation.profile &&
        args <= MainTabNavigation.notifications &&
        args != MainTabNavigation.chatbot) {
      return args;
    }
    return MainTabNavigation.home;
  }

  /// Maps bottom-nav index → PageView index (chatbot has no page).
  static int _pageForTab(int tabIndex) {
    if (tabIndex == MainTabNavigation.notifications) return 3;
    if (tabIndex == MainTabNavigation.chatbot) return 1;
    return tabIndex;
  }

  static int _tabForPage(int pageIndex) {
    if (pageIndex == 3) return MainTabNavigation.notifications;
    return pageIndex;
  }

  Future<void> selectTab(int index) async {
    if (index == MainTabNavigation.chatbot) {
      Get.toNamed(AppRoutes.chatbot);
      return;
    }
    // Always reveal nav when switching tabs.
    navVisible.value = true;
    if (index == currentIndex.value) return;
    currentIndex.value = index;
    if (!pageController.hasClients) return;
    await pageController.animateToPage(
      _pageForTab(index),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void onPageChanged(int pageIndex) {
    currentIndex.value = _tabForPage(pageIndex);
    navVisible.value = true;
  }

  /// Hide bar while scrolling down the feed; show again when scrolling up.
  bool handleScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;
    if (notification.metrics.axis != Axis.vertical) return false;

    final pixels = notification.metrics.pixels;
    final delta = notification.scrollDelta ?? 0;

    if (pixels <= 48) {
      if (!navVisible.value) navVisible.value = true;
      return false;
    }

    if (delta > _hideThreshold && navVisible.value) {
      navVisible.value = false;
    } else if (delta < -_hideThreshold && !navVisible.value) {
      navVisible.value = true;
    }
    return false;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

class MainShellScreen extends GetView<MainShellController> {
  const MainShellScreen({super.key});

  static const _pages = <Widget>[
    ProfileScreen(embedded: true),
    HomeScreen(embedded: true),
    ReelsScreen(embedded: true),
    NotificationScreen(embedded: true),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: NotificationListener<ScrollNotification>(
        onNotification: controller.handleScrollNotification,
        child: PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: controller.onPageChanged,
          children: _pages,
        ),
      ),
      bottomNavigationBar: Obx(() {
        final visible = controller.navVisible.value;
        return AnimatedSlide(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          offset: visible ? Offset.zero : const Offset(0, 1.4),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 180),
            opacity: visible ? 1 : 0,
            child: IgnorePointer(
              ignoring: !visible,
              child: AppBottomNavigation(
                currentIndex: controller.currentIndex.value,
                onTap: controller.selectTab,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Binding for the main tab shell and tab controllers (chatbot is route-only).
class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    HomeBinding().dependencies();
    ProfileBinding().dependencies();
    ReelsBinding().dependencies();
    NotificationBinding().dependencies();
    Get.lazyPut<MainShellController>(() => MainShellController(), fenix: true);
  }
}

/// Return to the shell (if needed), then select a tab with page motion.
void goToMainTab(int index) {
  if (index == MainTabNavigation.chatbot) {
    Get.toNamed(AppRoutes.chatbot);
    return;
  }

  if (Get.currentRoute != AppRoutes.home) {
    Get.until(
      (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  if (Get.isRegistered<MainShellController>()) {
    Get.find<MainShellController>().selectTab(index);
    return;
  }

  Get.offAllNamed(AppRoutes.home, arguments: index);
}
