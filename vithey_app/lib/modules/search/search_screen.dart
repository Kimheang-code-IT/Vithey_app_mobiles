import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_strings.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/modules/search/search_controller.dart';
import 'package:aub_connect_app/modules/search/widgets/search_app_bar.dart';
import 'package:aub_connect_app/modules/search/widgets/search_filter_bar.dart';
import 'package:aub_connect_app/modules/search/widgets/search_recent_section.dart';
import 'package:aub_connect_app/modules/search/widgets/search_results_view.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.appColors.bodyBackground,
      appBar: SearchAppBar(
        controller: controller.searchController,
        focusNode: controller.focusNode,
        onChanged: controller.onQueryChanged,
        onClear: controller.clearQuery,
        onSubmitted: controller.submitSearch,
        hintText:
            controller.pickUserForChat ? AppStrings.pickUserToChat : 'Search',
      ),
      body: Obx(() {
        if (controller.showRecent) {
          return SearchRecentSection(
            items: controller.visibleRecentItems,
            isLoading: controller.isLoadingRecents.value,
            onItemTap: controller.openRecentItem,
            onTogglePin: controller.toggleRecentPin,
            onRemove: controller.removeRecent,
            onClearAll: controller.pickUserForChat
                ? null
                : controller.confirmClearRecents,
            showActions: !controller.pickUserForChat,
            header: controller.pickUserForChat
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      AppStrings.pickUserToChat,
                      style: context.text.bodySmall,
                    ),
                  )
                : null,
          );
        }
        return Column(
          children: [
            if (!controller.pickUserForChat)
              SearchFilterBar(
                selected: controller.resultFilter.value,
                onSelected: controller.setResultFilter,
              ),
            Expanded(
              child: SearchResultsView(
                query: controller.query.value,
                isSearching: controller.isSearching.value,
                error: controller.searchError.value,
                people: controller.people,
                posts:
                    controller.pickUserForChat ? const [] : controller.posts,
                jobs: controller.pickUserForChat ? const [] : controller.jobs,
                videos:
                    controller.pickUserForChat ? const [] : controller.videos,
                peopleOnly: controller.pickUserForChat,
                filter: controller.pickUserForChat
                    ? SearchResultFilters.people
                    : controller.resultFilter.value,
                onRetry: controller.retrySearch,
                onPersonTap: controller.openPerson,
                onPersonMessage: controller.messagePerson,
                onPostTap: (post) => controller.openPost(post.id),
                onSeeAll: controller.openSeeAll,
              ),
            ),
          ],
        );
      }),
    );
  }
}
