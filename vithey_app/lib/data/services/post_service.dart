import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/comment_model.dart';
import 'package:aub_connect_app/data/models/feed_post.dart';

class PostService {
  PostService(this._api);

  final ApiService _api;

  Future<List<FeedPost>> fetchFeed({
    required int page,
    required int limit,
    String? currentUserId,
    PostType? type,
  }) async {
    final response = await _api.get<List<FeedPost>>(
      ApiEndpoints.posts,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (type != null) 'type': type.name.toUpperCase(),
      },
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>,
                currentUserId: currentUserId))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to load feed');
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
    final response = await _api.get<List<FeedPost>>(
      ApiEndpoints.userPosts(userId),
      queryParameters: {
        'type': type.name.toUpperCase(),
        'page': page,
        'limit': limit,
      },
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((item) => FeedPost.fromJson(item as Map<String, dynamic>,
                currentUserId: currentUserId))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to load user posts');
    }
    return response.data!;
  }

  Future<FeedPost> fetchPost(String postId, {String? currentUserId}) async {
    final response = await _api.get<FeedPost>(
      '${ApiEndpoints.posts}/$postId',
      fromJson: (json) => FeedPost.fromJson(json as Map<String, dynamic>,
          currentUserId: currentUserId),
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(response.error?.message ?? 'Post not found');
    }
    return response.data!;
  }

  Future<void> toggleReaction(String postId) async {
    final response = await _api.post<void>(
      ApiEndpoints.postReactions(postId),
      data: {},
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw PostServiceException(response.error?.message ?? 'Reaction failed');
    }
  }

  Future<void> followUser(String userId) async {
    final response = await _api.post<void>(
      ApiEndpoints.userFollow(userId),
      data: {},
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw PostServiceException(response.error?.message ?? 'Follow failed');
    }
  }

  Future<void> unfollowUser(String userId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.userFollow(userId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw PostServiceException(response.error?.message ?? 'Unfollow failed');
    }
  }

  Future<List<CommentModel>> fetchComments({
    required String postId,
    required int page,
    required int limit,
  }) async {
    final response = await _api.get<List<CommentModel>>(
      ApiEndpoints.postComments(postId),
      queryParameters: {'page': page, 'limit': limit},
      fromJson: (json) {
        final list = json as List<dynamic>? ?? [];
        return list
            .map((item) => CommentModel.fromJson(item as Map<String, dynamic>))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to load comments');
    }
    return response.data!;
  }

  Future<CommentModel> createComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    final response = await _api.post<CommentModel>(
      ApiEndpoints.postComments(postId),
      data: {
        'text': text,
        if (parentCommentId != null && parentCommentId.isNotEmpty)
          'parent_comment_id': parentCommentId,
      },
      fromJson: (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to post comment');
    }
    return response.data!;
  }

  Future<CommentModel> updateComment({
    required String postId,
    required String commentId,
    required String text,
  }) async {
    final response = await _api.patch<CommentModel>(
      ApiEndpoints.postCommentById(postId, commentId),
      data: {'text': text},
      fromJson: (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to update comment');
    }
    return response.data!;
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    final response = await _api.delete<void>(
      ApiEndpoints.postCommentById(postId, commentId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to delete comment');
    }
  }

  Future<FeedPost> createPost({
    required String type,
    required String content,
    String? mediaFileId,
    Map<String, dynamic>? jobMeta,
    DateTime? scheduledAt,
    String? currentUserId,
  }) async {
    final response = await _api.post<FeedPost>(
      ApiEndpoints.posts,
      data: {
        'type': type,
        'content': content,
        if (mediaFileId != null) 'media_file_id': mediaFileId,
        if (jobMeta != null) 'job_meta': jobMeta,
        if (scheduledAt != null)
          'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      },
      fromJson: (json) => FeedPost.fromJson(json as Map<String, dynamic>,
          currentUserId: currentUserId),
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
          response.error?.message ?? 'Failed to create post');
    }
    return response.data!;
  }

  Future<FeedPost> updatePost({
    required String postId,
    required String content,
    String? mediaFileId,
    bool removeMedia = false,
    Map<String, dynamic>? jobMeta,
    String? currentUserId,
  }) async {
    final response = await _api.patch<FeedPost>(
      ApiEndpoints.postById(postId),
      data: {
        'content': content,
        if (mediaFileId != null) 'media_file_id': mediaFileId,
        if (removeMedia) 'remove_media': true,
        if (jobMeta != null) 'job_meta': jobMeta,
      },
      fromJson: (json) => FeedPost.fromJson(
        json as Map<String, dynamic>,
        currentUserId: currentUserId,
      ),
    );
    if (!response.isSuccess || response.data == null) {
      throw PostServiceException(
        response.error?.message ?? 'Failed to update post',
      );
    }
    return response.data!;
  }

  Future<void> deletePost(String postId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.postById(postId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw PostServiceException(
        response.error?.message ?? 'Failed to delete post',
      );
    }
  }
}

class PostServiceException implements Exception {
  PostServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
