import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';
import 'package:aub_connect_app/data/models/user_profile_model.dart';

class ProfileService {
  ProfileService(this._api);

  final ApiService _api;

  Future<UserProfileModel> getUserProfile(String userId) async {
    final response = await _api.get<UserProfileModel>(
      ApiEndpoints.userById(userId),
      fromJson: (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw ProfileServiceException(response.error?.message ?? 'Profile not found');
    }
    return response.data!;
  }

  Future<UserProfileModel> getMyProfile() async {
    final response = await _api.get<UserProfileModel>(
      ApiEndpoints.usersMe,
      fromJson: (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw ProfileServiceException(response.error?.message ?? 'Profile not found');
    }
    return response.data!;
  }

  Future<List<FeedPost>> getUserPosts({
    required String userId,
    required PostType type,
    required int page,
    int limit = 10,
    String? currentUserId,
  }) async {
    final typeParam = type.name.toUpperCase();
    final response = await _api.get<List<FeedPost>>(
      ApiEndpoints.userPosts(userId),
      queryParameters: {'type': typeParam, 'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>, currentUserId: currentUserId))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw ProfileServiceException(response.error?.message ?? 'Failed to load posts');
    }
    return response.data!;
  }

  Future<UserProfileModel> updateMyProfile(Map<String, dynamic> fields) async {
    final response = await _api.patch<UserProfileModel>(
      ApiEndpoints.usersMe,
      data: fields,
      fromJson: (json) => UserProfileModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw ProfileServiceException(response.error?.message ?? 'Failed to update profile');
    }
    return response.data!;
  }
}

class ProfileServiceException implements Exception {
  ProfileServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
