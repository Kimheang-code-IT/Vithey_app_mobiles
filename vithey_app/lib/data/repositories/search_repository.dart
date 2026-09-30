import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/data/fixtures/search_fixtures.dart';
import 'package:aub_connect_app/data/local/search_recent_store.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/data/services/post_search_service.dart';
import 'package:aub_connect_app/data/services/user_search_service.dart';

class SearchRepository {
  SearchRepository(
    this._userSearchService,
    this._postSearchService,
    this._recentStore,
    this._flags,
  );

  final UserSearchService _userSearchService;
  final PostSearchService _postSearchService;
  final SearchRecentStore _recentStore;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockSearch;

  static const previewLimit = 3;

  Future<List<SearchRecentItem>> loadRecents() => _recentStore.getRecentItems();

  Future<void> ensureDefaultRecents() {
    if (!useMockApi) return Future.value();
    return _recentStore.seedDefaultsIfEmpty(SearchFixtures.defaultRecents());
  }

  Future<void> addRecentUser(UserSearchResult user) =>
      _recentStore.addRecentFromResult(user);

  Future<void> addRecentQuery(String query) =>
      _recentStore.addRecentQuery(query);

  Future<void> setRecentPinned(String itemId, bool pinned) =>
      _recentStore.setPinned(itemId, pinned);

  Future<void> removeRecent(String itemId) => _recentStore.removeRecent(itemId);

  Future<void> clearAllRecents({bool includePinned = false}) =>
      _recentStore.clearAll(includePinned: includePinned);

  Future<SearchResultsBundle> searchAll(String query) async {
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      return const SearchResultsBundle();
    }

    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 350));
      return _mockSearchAll(trimmed);
    }

    return _searchAllFromApi(trimmed);
  }

  Future<SearchResultsBundle> _searchAllFromApi(String query) async {
    Object? firstError;

    Future<PaginatedResult<UserSearchResult>> peopleSearch() =>
        _userSearchService.search(query: query, limit: previewLimit);

    Future<PaginatedResult<PostSearchResult>> postSearch(PostType type) =>
        _postSearchService.search(
            query: query, type: type, limit: previewLimit);

    PaginatedResult<UserSearchResult> peopleResult;
    try {
      peopleResult = await peopleSearch();
    } catch (e) {
      firstError ??= e;
      peopleResult = const PaginatedResult(items: [], hasMore: false);
    }

    PaginatedResult<PostSearchResult> postsResult;
    try {
      postsResult = await postSearch(PostType.poster);
    } catch (e) {
      firstError ??= e;
      postsResult = const PaginatedResult(items: [], hasMore: false);
    }

    PaginatedResult<PostSearchResult> jobsResult;
    try {
      jobsResult = await postSearch(PostType.job);
    } catch (e) {
      firstError ??= e;
      jobsResult = const PaginatedResult(items: [], hasMore: false);
    }

    PaginatedResult<PostSearchResult> videosResult;
    try {
      videosResult = await postSearch(PostType.video);
    } catch (e) {
      firstError ??= e;
      videosResult = const PaginatedResult(items: [], hasMore: false);
    }

    final bundle = SearchResultsBundle(
      people: peopleResult.items,
      posts: postsResult.items,
      jobs: jobsResult.items,
      videos: videosResult.items,
    );

    if (bundle.isEmpty && firstError != null) {
      throw firstError;
    }

    return bundle;
  }

  Future<PaginatedResult<UserSearchResult>> searchPeople({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final all = _filterMockUsers(query);
      final start = (page - 1) * limit;
      final slice = all.skip(start).take(limit).toList();
      return PaginatedResult(items: slice, hasMore: start + limit < all.length);
    }
    return _userSearchService.search(query: query, page: page, limit: limit);
  }

  Future<PaginatedResult<PostSearchResult>> searchPosts({
    required String query,
    PostType? type,
    int page = 1,
    int limit = 10,
  }) async {
    if (useMockApi) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      final all = _filterMockPosts(query, type: type);
      final start = (page - 1) * limit;
      final slice = all.skip(start).take(limit).toList();
      return PaginatedResult(items: slice, hasMore: start + limit < all.length);
    }
    return _postSearchService.search(
        query: query, type: type, page: page, limit: limit);
  }

  SearchResultsBundle _mockSearchAll(String query) {
    final people = _filterMockUsers(query).take(previewLimit).toList();
    final posters = _filterMockPosts(query, type: PostType.poster)
        .take(previewLimit)
        .toList();
    final jobs =
        _filterMockPosts(query, type: PostType.job).take(previewLimit).toList();
    final videos = _filterMockPosts(query, type: PostType.video)
        .take(previewLimit)
        .toList();
    return SearchResultsBundle(
      people: people,
      posts: posters,
      jobs: jobs,
      videos: videos,
    );
  }

  List<UserSearchResult> _filterMockUsers(String query) {
    final q = query.toLowerCase();
    return SearchFixtures.users()
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            (u.major?.toLowerCase().contains(q) ?? false) ||
            (u.university?.toLowerCase().contains(q) ?? false) ||
            (u.headline?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  List<PostSearchResult> _filterMockPosts(String query, {PostType? type}) {
    final q = query.toLowerCase();
    return SearchFixtures.posts().where((post) {
      if (type != null && post.type != type) return false;
      return post.title.toLowerCase().contains(q) ||
          post.authorName.toLowerCase().contains(q) ||
          (post.jobCompany?.toLowerCase().contains(q) ?? false);
    }).toList();
  }
}
