import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/modules/home/home_controller.dart';
import 'package:aub_connect_app/modules/home/widgets/home_media_header.dart';
import 'package:aub_connect_app/modules/home/widgets/mixed_post_feed.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key, this.embedded = false});

  /// When true, used inside [MainShellScreen] (no own bottom bar).
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? context.appColors.bodyBackground
          : context.scheme.surfaceContainerLow,
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => MixedPostFeed(
            topSlivers: [
              HomeFlexibleHeader(
                items: controller.mediaStories,
                onOpenOwnMedia: () =>
                    controller.openCreatePost(type: PostType.poster),
                onOpenItem: controller.openMediaItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
