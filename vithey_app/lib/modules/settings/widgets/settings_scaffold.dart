import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/navigation/main_tab_navigation.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_bottom_navigation.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';

/// Settings shell with iOS-style large title:
/// - At rest / top: big left title under the back button
/// - On scroll: title collapses to the centered app-bar position
class SettingsScaffold extends StatelessWidget {
  const SettingsScaffold({
    super.key,
    required this.title,
    required this.body,
    this.floatingActionButton,
  });

  final String title;
  final Widget body;
  final Widget? floatingActionButton;

  static const _expandedExtra = 52.0;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final pageBg = colors.inputFill;

    return Scaffold(
      backgroundColor: pageBg,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: MainTabNavigation.profile,
        onTap: (index) => MainTabNavigation.handle(
          index,
          currentIndex: MainTabNavigation.profile,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: AppBottomNavigation.scrollClearance(context),
        ),
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                pinned: true,
                expandedHeight: kToolbarHeight + _expandedExtra,
                backgroundColor: pageBg,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                forceElevated: false,
                leading: IconButton(
                  icon: Icon(
                    LucideIcons.arrowLeft,
                    size: 20,
                    color: colors.heading,
                  ),
                  onPressed: () => Get.back(),
                ),
                centerTitle: true,
                title: AnimatedOpacity(
                  opacity: innerBoxIsScrolled ? 1 : 0,
                  duration: const Duration(milliseconds: 120),
                  child: Text(
                    title,
                    style: context.text.titleLarge?.copyWith(fontSize: 17),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _SettingsLargeTitle(title: title),
                ),
              ),
            ];
          },
          body: body,
        ),
      ),
    );
  }
}

class _SettingsLargeTitle extends StatelessWidget {
  const _SettingsLargeTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final settings =
        context.dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final t = settings == null
        ? 0.0
        : (1.0 -
                (settings.currentExtent - settings.minExtent) /
                    (settings.maxExtent - settings.minExtent))
            .clamp(0.0, 1.0);

    // Fade out the large title as the bar collapses.
    final opacity = (1.0 - Curves.easeOut.transform(t)).clamp(0.0, 1.0);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Opacity(
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.headlineSmall?.copyWith(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.3,
            ),
          ),
        ),
      ),
    );
  }
}
