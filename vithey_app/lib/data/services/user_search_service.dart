import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/search_result_models.dart';

class UserSearchService {
  UserSearchService(this._api);

  final ApiService _api;

  Future<PaginatedResult<UserSearchResult>> search({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _api.get<List<UserSearchResult>>(
      ApiEndpoints.usersSearch,
      queryParameters: {
        'search': query,
        'page': page,
        'limit': limit,
      },
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((item) => UserSearchResult.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw UserSearchServiceException(response.error?.message ?? 'Search failed');
    }
    final totalPages = response.meta?.totalPages;
    final hasMore = totalPages != null && totalPages > 0
        ? page < totalPages
        : response.data!.length >= limit;
    return PaginatedResult(items: response.data!, hasMore: hasMore);
  }
}

class UserSearchServiceException implements Exception {
  UserSearchServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
