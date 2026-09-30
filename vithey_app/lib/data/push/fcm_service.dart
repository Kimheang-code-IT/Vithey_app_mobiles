import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:aub_connect_app/core/alerts/in_app_alert_service.dart';
import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:get/get.dart';
import 'package:aub_connect_app/data/models/app_notification_model.dart';
import 'package:aub_connect_app/data/push/notification_router.dart';
import 'package:aub_connect_app/data/repositories/notification_repository.dart';
import 'package:aub_connect_app/data/repositories/settings_repository.dart';
import 'package:aub_connect_app/data/services/notification_service.dart';

/// Firebase push wrapper — enable with FCM_ENABLED=true after Firebase setup.
class FcmService {
  FcmService(this._notificationService, this._flags);

  final NotificationService _notificationService;
  final FeatureFlags _flags;

  String? _cachedToken;

  bool get enabled => _flags.fcmEnabled;

  bool get _useMockApi => _flags.useMockNotifications;

  Future<void> init() async {
    if (!enabled) return;

    // When firebase_messaging is configured:
    // await Firebase.initializeApp();
    // FirebaseMessaging.onMessage.listen((m) => handlePushData(m.data));
    // FirebaseMessaging.onMessageOpenedApp.listen(
    //     (m) => handlePushData(m.data, userTapped: true));
    // final initial = await FirebaseMessaging.instance.getInitialMessage();
    // if (initial != null) handlePushData(initial.data, userTapped: true);

    final debugToken = AppConfig.instance.fcmDebugToken;
    if (debugToken != null && debugToken.isNotEmpty) {
      _cachedToken = debugToken;
    }
  }

  Future<void> registerToken() async {
    if (!enabled || _useMockApi) return;

    // Don't register a device token when the user turned notifications off.
    if (Get.isRegistered<SettingsRepository>()) {
      final preferences = await Get.find<SettingsRepository>()
          .loadCachedNotificationPreferences();
      if (!preferences.allowNotifications) return;
    }

    // final token = _cachedToken ?? await FirebaseMessaging.instance.getToken();
    final token = _cachedToken ?? AppConfig.instance.fcmDebugToken;
    if (token == null || token.isEmpty) return;

    await _notificationService.registerDevice(
      fcmToken: token,
      platform: _platform,
    );
    _cachedToken = token;
  }

  Future<void> unregisterToken() async {
    if (!enabled || _useMockApi) return;
    final token = _cachedToken;
    if (token == null || token.isEmpty) return;

    try {
      await _notificationService.unregisterDevice(token);
    } finally {
      _cachedToken = null;
    }
  }

  /// Whether the user's saved notification preferences allow delivering a
  /// notification of [type]. Checks the master switch plus category toggles.
  Future<bool> shouldDeliver(NotificationType type, {String? event}) async {
    if (!Get.isRegistered<SettingsRepository>()) return true;
    final preferences = await Get.find<SettingsRepository>()
        .loadCachedNotificationPreferences();
    return preferences.allowsType(type, event: event);
  }

  Future<void> handlePushData(
    Map<String, dynamic> data, {
    bool userTapped = false,
  }) async {
    final repository = Get.find<NotificationRepository>();
    final notification = NotificationService.fromJson({
      'id': data['notification_id'] ?? data['id'] ?? '',
      'type': data['type'],
      'event': data['event'],
      'title': data['title'] ?? '',
      'body': data['body'] ?? '',
      'is_read': false,
      'created_at': DateTime.now().toIso8601String(),
      'actor': {
        if (data['actor_id'] != null) 'id': data['actor_id'],
        if (data['actor_name'] != null) 'full_name': data['actor_name'],
      },
      'destination': {
        'reference_type': data['reference_type'],
        'reference_id': data['reference_id'],
        'post_id': data['post_id'],
        'conversation_id': data['conversation_id'],
        'job_post_id': data['job_post_id'],
        'application_id': data['application_id'],
        'payment_id': data['payment_id'],
        'ai_thread_id': data['ai_thread_id'],
      },
      'dedupe_key': data['dedupe_key'],
    });

    // Drop the notification when the user's preferences mute this category,
    // unless the user explicitly tapped it in the OS tray.
    if (!userTapped &&
        !await shouldDeliver(notification.type, event: notification.event)) {
      return;
    }

    if (notification.id.isNotEmpty) {
      repository.cacheNotification(notification);
      repository.reconcileUnreadCount();
    }

    // Foreground chat pushes → in-app heads-up (tap still deep-links below).
    if (!userTapped &&
        Get.isRegistered<InAppAlertService>() &&
        (notification.type == NotificationType.chatMessage ||
            notification.type == NotificationType.chatRequest)) {
      final conversationId = notification.destination.conversationId;
      if (conversationId != null && conversationId.isNotEmpty) {
        await Get.find<InAppAlertService>().showChatMessage(
          conversationId: conversationId,
          senderName: notification.actor?.fullName ??
              (notification.title.isNotEmpty ? notification.title : 'New message'),
          text: notification.body.isNotEmpty ? notification.body : notification.title,
          senderAvatarUrl: notification.actor?.avatarUrl,
          participantId: notification.actor?.id,
          createdAt: notification.createdAt,
        );
        return;
      }
    }

    if (userTapped) {
      NotificationRouter.routeFromPushData(data);
    }
  }

  String get _platform {
    if (kIsWeb) return 'ANDROID';
    return Platform.isIOS ? 'IOS' : 'ANDROID';
  }
}
