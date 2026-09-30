import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/core/constants/app_colors.dart';
import 'package:aub_connect_app/core/constants/app_routes.dart';
import 'package:aub_connect_app/core/theme/app_semantic_colors.dart';
import 'package:aub_connect_app/core/widgets/vithey_text_link.dart';
import 'package:aub_connect_app/data/models/search_args.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/repositories/search_repository.dart';
import 'package:aub_connect_app/modules/search/widgets/search_empty_state.dart';
import 'package:aub_connect_app/modules/search/widgets/search_filter_bar.dart';
import 'package:aub_connect_app/modules/search/widgets/search_job_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_loading_skeleton.dart';
import 'package:aub_connect_app/modules/search/widgets/search_person_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_post_tile.dart';
import 'package:aub_connect_app/modules/search/widgets/search_section_header.dart';
import 'package:aub_connect_app/modules/search/widgets/search_video_tile.dart';

import 'package:aub_connect_app/core/icons/vithey_icons.dart';
class SearchResultsView extends StatelessWidget {
  const SearchResultsView({
    super.key,
    required this.query,
    required this.isSearching,
    required this.error,
    required this.people,
    required this.posts,
    required this.jobs,
    required this.videos,
    required this.onRetry,
    required this.onPersonTap,
    required this.onPersonMessage,
    required this.onPostTap,
    required this.onSeeAll,
    this.peopleOnly = false,
    this.filter = SearchResultFilters.all,
  });

  final String query;
  final bool isSearching;
  final String? error;
  final List<UserSearchResult> people;
  final List<PostSearchResult> posts;
  final List<PostSearchResult> jobs;
  final List<PostSearchResult> videos;
  final VoidCallback onRetry;
  final ValueChanged<UserSearchResult> onPersonTap;
  final ValueChanged<UserSearchResult> onPersonMessage;
  final ValueChanged<PostSearchResult> onPostTap;
  final ValueChanged<SearchSeeAllCategory> onSeeAll;
  final bool peopleOnly;
  final String filter;

  bool get _hasAny =>
      people.isNotEmpty ||
      posts.isNotEmpty ||
      jobs.isNotEmpty ||
      videos.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    if (query.trim().length == 1) {
      return Center(
        child: Text(
          'Type at least 2 characters',
          style: TextStyle(color: context.appColors.muted),
        ),
      );
    }

    if (error != null && !_hasAny && !isSearching) {
      return _ErrorBanner(message: error!, onRetry: onRetry);
    }

    if (isSearching && !_hasAny) {
      return const SearchLoadingSkeleton();
    }

    if (!_hasAny && !isSearching) {
      return SearchEmptyState(query: peopleOnly ? 'people' : query);
    }

    final showPeople = peopleOnly ||
        filter == SearchResultFilters.all ||
        filter == SearchResultFilters.people;
    final showPosts =
        !peopleOnly && filter == SearchResultFilters.posts;
    final showJobs = !peopleOnly && filter == SearchResultFilters.jobs;
    final showVideos =
        !peopleOnly && filter == SearchResultFilters.videos;
    final showPlaces = !peopleOnly && filter == SearchResultFilters.all;

    if (!showPeople && !showPosts && !showJobs && !showVideos) {
      return SearchEmptyState(query: query);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (error != null) _ErrorBanner(message: error!, onRetry: onRetry),
        if (showPlaces && query.trim().length >= 2)
          _PlacesOnMapTile(query: query.trim()),
        if (showPeople && people.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'People',
            showSeeAll:
                !peopleOnly && people.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.people),
          ),
          ...people.map(
            (person) => SearchPersonTile(
              person: person,
              query: query,
              onTap: () => onPersonTap(person),
              onMessage: () => onPersonMessage(person),
            ),
          ),
        ],
        if (showPosts && posts.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Posts',
            showSeeAll: posts.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.posts),
          ),
          ...posts.map(
            (post) => SearchPostTile(
              post: post,
              query: query,
              onTap: () => onPostTap(post),
            ),
          ),
        ],
        if (showJobs && jobs.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Jobs',
            showSeeAll: jobs.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.jobs),
          ),
          ...jobs.map(
            (job) => SearchJobTile(
              job: job,
              query: query,
              onTap: () => onPostTap(job),
            ),
          ),
        ],
        if (showVideos && videos.isNotEmpty) ...[
          SearchSectionHeader(
            title: 'Videos',
            showSeeAll: videos.length >= SearchRepository.previewLimit,
            onSeeAll: () => onSeeAll(SearchSeeAllCategory.videos),
          ),
          ...videos.map(
            (video) => SearchVideoTile(
              video: video,
              query: query,
              onTap: () => onPostTap(video),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Places on map" entry — GenZ card with a tinted squircle lead icon.
class _PlacesOnMapTile extends StatelessWidget {
  const _PlacesOnMapTile({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
      child: Material(
        color: colors.cardSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Get.toNamed(AppRoutes.map, arguments: query),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child:
                      const VitheyIcon(LucideIcons.map, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Places on map',
                        style: context.text.labelLarge,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Search "$query" near you',
                        style: context.text.bodySmall
                            ?.copyWith(fontSize: 12.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                VitheyIcon(LucideIcons.chevronRight, color: colors.muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      decoration: BoxDecoration(
        color: colors.cardSurface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: VitheyIcon(
              LucideIcons.circleAlert,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: context.text.bodySmall
                  ?.copyWith(fontSize: 13.5, color: colors.heading),
            ),
          ),
          VitheyTextLink(label: 'Retry', onPressed: onRetry),
        ],
      ),
    );
  }
}
