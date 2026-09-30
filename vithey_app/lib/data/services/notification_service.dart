import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/models/notification_page_result.dart';

class NotificationService {
  NotificationService(this._api);

  final ApiService _api;

  Future<NotificationPageResult> fetchNotifications({
    int page = 1,
    int limit = 20,
    bool? isRead,
  }) async {
    final response = await _api.get<List<AppNotification>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (isRead != null) 'is_read': isRead,
      },
      fromJson: (json) {
        final list = json is List
            ? json
            : (json as Map<String, dynamic>?)?['data'] as List? ?? [];
        return list
            .map((item) => _parseNotification(item as Map<String, dynamic>))
            .toList();
      },
    );
    if (!response.isSuccess || response.data == null) {
      throw NotificationServiceException(
        response.error?.message ?? 'Failed to load notifications',
      );
    }

    final meta = response.meta;
    final items = response.data!;
    final total = meta?.total ?? items.length;
    final limitValue = meta?.limit ?? limit;
    final unreadTotal = _readUnreadTotal(meta);

    return NotificationPageResult(
      items: items,
      total: total,
      unreadTotal: unreadTotal,
      hasMore: meta != null
          ? meta.page * meta.limit < total
          : items.length >= limitValue,
    );
  }

  int? _readUnreadTotal(dynamic meta) {
    if (meta == null) return null;
    // ApiMeta does not model unread_total yet; read from raw if backend sends it.
    return null;
  }

  AppNotification parseNotification(Map<String, dynamic> json) =>
      fromJson(json);

  static AppNotification fromJson(Map<String, dynamic> json) {
    return NotificationService._parseNotificationStatic(json);
  }

  AppNotification _parseNotification(Map<String, dynamic> json) =>
      fromJson(json);

  static AppNotification _parseNotificationStatic(Map<String, dynamic> json) {
    final actorJson = json['actor'] as Map<String, dynamic>?;
    final destJson = json['destination'] as Map<String, dynamic>? ?? {};
    final event = json['event']?.toString();
    final referenceId = destJson['reference_id']?.toString() ??
        json['reference_id']?.toString();

    return AppNotification(
      id: json['id']?.toString() ?? json['notification_id']?.toString() ?? '',
      type: _parseTypeStatic(json['type']?.toString(), event),
      event: event,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      actor: actorJson == null
          ? null
          : NotificationActor(
              id: actorJson['id']?.toString() ?? '',
              fullName: actorJson['full_name'] as String? ??
                  actorJson['fullName'] as String? ??
                  '',
              avatarUrl: actorJson['avatar_url'] as String? ??
                  actorJson['avatarUrl'] as String?,
            ),
      destination: NotificationDestination(
        referenceType: destJson['reference_type'] as String? ??
            json['reference_type'] as String?,
        referenceId: referenceId,
        postId: destJson['post_id']?.toString() ?? referenceId,
        commentId: destJson['comment_id']?.toString(),
        userId: destJson['user_id']?.toString(),
        conversationId: destJson['conversation_id']?.toString() ?? referenceId,
        jobPostId: destJson['job_post_id']?.toString(),
        applicationId: destJson['application_id']?.toString(),
        paymentId: destJson['payment_id']?.toString(),
        aiThreadId: destJson['ai_thread_id']?.toString(),
        routeName: destJson['route_name'] as String?,
      ),
      isRead: json['is_read'] as bool? ?? false,
      dedupeKey: json['dedupe_key'] as String?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static NotificationType _parseTypeStatic(String? raw, String? event) {
    return switch (raw?.toUpperCase()) {
      'LIKE' => NotificationType.postLike,
      'COMMENT' => NotificationType.postComment,
      'MENTION' => NotificationType.postMention,
      'POST_SHARE' || 'SHARE' => NotificationType.postShare,
      'FOLLOW' => NotificationType.newFollower,
      'CHAT_REQUEST' => NotificationType.chatRequest,
      'CHAT' || 'CHAT_MESSAGE' => NotificationType.chatMessage,
      'JOB' ||
      'JOB_APPLICATION' ||
      'JOB_STATUS' =>
        event == 'job.application.status_changed'
            ? NotificationType.jobApplicationStatus
            : NotificationType.jobApplicationReceived,
      'PAYMENT' || 'PAYMENT_ALERT' => event == 'payment.overdue'
          ? NotificationType.paymentOverdue
          : NotificationType.paymentDue,
      'AI' => NotificationType.aiAssistantResponse,
      'SYSTEM' => NotificationType.system,
      'STUDENT_VERIFICATION' => NotificationType.studentVerification,
      _ => NotificationType.system,
    };
  }

  Future<int> fetchUnreadCount() async {
    final response = await _api.get<int>(
      ApiEndpoints.notificationsUnreadCount,
      fromJson: (json) {
        if (json is int) return json;
        if (json is Map<String, dynamic>) {
          return json['count'] as int? ?? json['unread_count'] as int? ?? 0;
        }
        return 0;
      },
    );
    if (!response.isSuccess || response.data == null) return 0;
    return response.data!;
  }

  Future<void> markRead(String notificationId) async {
    final response = await _api.patch<void>(
      ApiEndpoints.notificationRead(notificationId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(
          response.error?.message ?? 'Failed to mark read');
    }
  }

  Future<int> markAllRead() async {
    final response = await _api.patch<int>(
      ApiEndpoints.notificationsReadAll,
      fromJson: (json) {
        if (json is int) return json;
        if (json is Map<String, dynamic>) {
          return json['updated_count'] as int? ?? json['count'] as int? ?? 0;
        }
        return 0;
      },
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(
          response.error?.message ?? 'Failed to mark all read');
    }
    return response.data ?? 0;
  }

  Future<void> deleteNotification(String notificationId) async {
    final response = await _api.delete<void>(
      ApiEndpoints.notificationById(notificationId),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(
          response.error?.message ?? 'Failed to delete');
    }
  }

  Future<void> registerDevice({
    required String fcmToken,
    required String platform,
  }) async {
    final response = await _api.post<void>(
      ApiEndpoints.notificationsDevices,
      data: {
        'fcm_token': fcmToken,
        'platform': platform,
      },
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(
          response.error?.message ?? 'Failed to register device');
    }
  }

  Future<void> unregisterDevice(String fcmToken) async {
    final response = await _api.delete<void>(
      ApiEndpoints.notificationDeviceByToken(Uri.encodeComponent(fcmToken)),
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw NotificationServiceException(
          response.error?.message ?? 'Failed to unregister device');
    }
  }
}

class NotificationServiceException implements Exception {
  NotificationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
