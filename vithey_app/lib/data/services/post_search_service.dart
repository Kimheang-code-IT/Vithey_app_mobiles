import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';
import 'package:aub_connect_app/core/session/current_user_service.dart';
import 'package:get/get.dart';

class PostSearchService {
  PostSearchService(this._api);

  final ApiService _api;

  Future<PaginatedResult<PostSearchResult>> search({
    required String query,
    PostType? type,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, dynamic>{
      'search': query,
      'page': page,
      'limit': limit,
    };
    if (type != null) {
      params['type'] = type.name.toUpperCase();
    }

    final response = await _api.get<List<FeedPost>>(
      ApiEndpoints.posts,
      queryParameters: params,
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map(
              (item) => FeedPost.fromJson(
                item as Map<String, dynamic>,
                currentUserId: Get.find<CurrentUserService>().userId,
              ),
            )
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PostSearchServiceException(response.error?.message ?? 'Search failed');
    }
    final items = response.data!.map(PostSearchResult.fromFeedPost).toList();
    final totalPages = response.meta?.totalPages;
    final hasMore = totalPages != null && totalPages > 0
        ? page < totalPages
        : items.length >= limit;
    return PaginatedResult(items: items, hasMore: hasMore);
  }
}

class PostSearchServiceException implements Exception {
  PostSearchServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
