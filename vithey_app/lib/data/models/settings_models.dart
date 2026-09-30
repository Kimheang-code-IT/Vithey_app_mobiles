import 'package:aub_connect_app/data/models/app_notification_model.dart';

class PrivacySettings {
  const PrivacySettings({
    this.profileVisible = true,
    this.dataSharing = false,
    this.activityTracking = false,
  });

  final bool profileVisible;
  final bool dataSharing;
  final bool activityTracking;

  PrivacySettings copyWith({
    bool? profileVisible,
    bool? dataSharing,
    bool? activityTracking,
  }) {
    return PrivacySettings(
      profileVisible: profileVisible ?? this.profileVisible,
      dataSharing: dataSharing ?? this.dataSharing,
      activityTracking: activityTracking ?? this.activityTracking,
    );
  }

  factory PrivacySettings.fromJson(Map<String, dynamic> json) {
    final privacy = json['privacy'] as Map<String, dynamic>? ?? json;
    return PrivacySettings(
      profileVisible: privacy['profile_visible'] as bool? ?? true,
      dataSharing: privacy['data_sharing'] as bool? ?? false,
      activityTracking: privacy['activity_tracking'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'privacy': {
          'profile_visible': profileVisible,
          'data_sharing': dataSharing,
          'activity_tracking': activityTracking,
        },
      };
}

class NotificationPreferences {
  const NotificationPreferences({
    this.allowNotifications = true,
    this.chatMessages = true,
    this.reminders = true,
    this.announcements = false,
    this.appUpdates = true,
  });

  final bool allowNotifications;
  final bool chatMessages;
  final bool reminders;
  final bool announcements;
  final bool appUpdates;

  NotificationPreferences copyWith({
    bool? allowNotifications,
    bool? chatMessages,
    bool? reminders,
    bool? announcements,
    bool? appUpdates,
  }) {
    return NotificationPreferences(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      chatMessages: chatMessages ?? this.chatMessages,
      reminders: reminders ?? this.reminders,
      announcements: announcements ?? this.announcements,
      appUpdates: appUpdates ?? this.appUpdates,
    );
  }

  factory NotificationPreferences.fromJson(
    Map<String, dynamic> json, {
    NotificationPreferences fallback = const NotificationPreferences(),
  }) {
    final notifications =
        json['notifications'] as Map<String, dynamic>? ?? json;
    return NotificationPreferences(
      allowNotifications:
          notifications['enabled'] as bool? ?? fallback.allowNotifications,
      chatMessages:
          notifications['chat_messages'] as bool? ?? fallback.chatMessages,
      reminders: notifications['reminders'] as bool? ?? fallback.reminders,
      announcements:
          notifications['announcements'] as bool? ?? fallback.announcements,
      appUpdates: notifications['app_updates'] as bool? ?? fallback.appUpdates,
    );
  }

  Map<String, dynamic> toJson() => {
        'notifications': {
          'enabled': allowNotifications,
          'chat_messages': chatMessages,
          'reminders': reminders,
          'announcements': announcements,
          'app_updates': appUpdates,
        },
      };

  /// Whether a notification of [type] may be delivered to the user.
  ///
  /// Category mapping:
  /// - Chat Messages: chat messages and chat requests
  /// - Reminders: payment due / overdue alerts
  /// - Announcements: system notifications (App Updates when the event is
  ///   `system.app_update`)
  /// - Other activity (likes, comments, follows, jobs, AI, verification) is
  ///   gated by the master switch only.
  bool allowsType(NotificationType type, {String? event}) {
    if (!allowNotifications) return false;
    return switch (type) {
      NotificationType.chatMessage ||
      NotificationType.chatRequest =>
        chatMessages,
      NotificationType.paymentDue ||
      NotificationType.paymentOverdue =>
        reminders,
      NotificationType.system =>
        event == 'system.app_update' ? appUpdates : announcements,
      _ => true,
    };
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NotificationPreferences &&
            other.allowNotifications == allowNotifications &&
            other.chatMessages == chatMessages &&
            other.reminders == reminders &&
            other.announcements == announcements &&
            other.appUpdates == appUpdates;
  }

  @override
  int get hashCode => Object.hash(
        allowNotifications,
        chatMessages,
        reminders,
        announcements,
        appUpdates,
      );
}

class UserSettingsModel {
  const UserSettingsModel({
    this.themeMode = 'light',
    this.language = 'en',
    this.privacy = const PrivacySettings(),
    this.notifications = const NotificationPreferences(),
  });

  final String themeMode;
  final String language;
  final PrivacySettings privacy;
  final NotificationPreferences notifications;

  UserSettingsModel copyWith({
    String? themeMode,
    String? language,
    PrivacySettings? privacy,
    NotificationPreferences? notifications,
  }) {
    return UserSettingsModel(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      privacy: privacy ?? this.privacy,
      notifications: notifications ?? this.notifications,
    );
  }

  factory UserSettingsModel.fromJson(
    Map<String, dynamic> json, {
    NotificationPreferences notificationFallback =
        const NotificationPreferences(),
  }) {
    return UserSettingsModel(
      themeMode: json['theme_mode'] as String? ?? 'light',
      language: json['language'] as String? ?? 'en',
      privacy: PrivacySettings.fromJson(json),
      notifications: NotificationPreferences.fromJson(
        json,
        fallback: notificationFallback,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'theme_mode': themeMode,
        'language': language,
        ...privacy.toJson(),
        ...notifications.toJson(),
      };
}
