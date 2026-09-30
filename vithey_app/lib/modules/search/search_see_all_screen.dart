import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/app_error_widget.dart';
import 'package:aub_connect_app/core/widgets/loading_widget.dart';
import 'package:aub_connect_app/core/widgets/shimmer_list_tile.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';
import 'package:aub_connect_app/modules/search/search_see_all_controller.dart';
import 'package:aub_connect_app/modules/search/widgets/search_empty_state.dart';
import 'package:aub_connect_app/modules/search/widgets/search_job_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_person_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_post_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_video_tile.dart';

class SearchSeeAllBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments as SearchSeeAllArgs;
    Get.lazyPut(
        () => SearchSeeAllController(Get.find<SearchRepository>(), args));
  }
}

class SearchSeeAllScreen extends GetView<SearchSeeAllController> {
  const SearchSeeAllScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = controller.args;

    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: AppBar(
        title: Text(args.title),
        backgroundColor: context.appColors.bodyBackground,
        foregroundColor: context.appColors.heading,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: context.appColors.border),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const LoadingWidget();
        }
        if (controller.hasError.value) {
          return AppErrorWidget(
              message: 'Search failed', onRetry: controller.loadFirstPage);
        }

        if (controller.isPeople) {
          if (controller.people.isEmpty) {
            return SearchEmptyState(query: args.query);
          }
          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 120) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: controller.people.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= controller.people.length) {
                  return const ShimmerListTile();
                }
                final person = controller.people[index];
                return SearchPersonTile(
                  person: person,
                  query: args.query,
                  onTap: () => controller.openPerson(person),
                  onMessage: () => controller.messagePerson(person),
                );
              },
            ),
          );
        }

        if (controller.posts.isEmpty) {
          return SearchEmptyState(query: args.query);
        }

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 120) {
              controller.loadMore();
            }
            return false;
          },
          child: ListView.builder(
            itemCount: controller.posts.length +
                (controller.isLoadingMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= controller.posts.length) {
                return const ShimmerListTile();
              }
              final post = controller.posts[index];
              return _buildPostTile(post, args);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPostTile(PostSearchResult post, SearchSeeAllArgs args) {
    switch (args.category) {
      case SearchSeeAllCategory.jobs:
        return SearchJobTile(
          job: post,
          query: args.query,
          onTap: () => controller.openPost(post.id),
        );
      case SearchSeeAllCategory.videos:
        return SearchVideoTile(
          video: post,
          query: args.query,
          onTap: () => controller.openPost(post.id),
        );
      case SearchSeeAllCategory.posts:
        return SearchPostTile(
          post: post,
          query: args.query,
          onTap: () => controller.openPost(post.id),
        );
      case SearchSeeAllCategory.people:
        throw StateError('People category uses a separate list');
    }
  }
}
