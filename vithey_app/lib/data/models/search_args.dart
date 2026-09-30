import 'package:aub_connect_app/data/models/feed_post.dart';

enum SearchMode {
  /// Default global search — navigate to profile/posts.
  browse,

  /// Opened from chat Add Chat — pick a user to message.
  pickUserForChat,
}

class SearchArgs {
  const SearchArgs({
    this.initialQuery,
    this.mode = SearchMode.browse,
  });

  final String? initialQuery;
  final SearchMode mode;

  static SearchArgs? from(dynamic arguments) {
    if (arguments == null) return null;
    if (arguments is SearchArgs) return arguments;
    if (arguments is String) return SearchArgs(initialQuery: arguments);
    return null;
  }
}

enum SearchSeeAllCategory { people, posts, jobs, videos }

class SearchSeeAllArgs {
  const SearchSeeAllArgs({
    required this.category,
    required this.query,
  });

  final SearchSeeAllCategory category;
  final String query;

  String get title {
    switch (category) {
      case SearchSeeAllCategory.people:
        return 'People';
      case SearchSeeAllCategory.posts:
        return 'Posts';
      case SearchSeeAllCategory.jobs:
        return 'Jobs';
      case SearchSeeAllCategory.videos:
        return 'Videos';
    }
  }

  PostType? get postType {
    switch (category) {
      case SearchSeeAllCategory.posts:
        return PostType.poster;
      case SearchSeeAllCategory.jobs:
        return PostType.job;
      case SearchSeeAllCategory.videos:
        return PostType.video;
      case SearchSeeAllCategory.people:
        return null;
    }
  }
}
