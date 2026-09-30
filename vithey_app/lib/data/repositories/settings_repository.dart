import 'package:aub_connect_app/core/config/feature_flags.dart';
import 'package:aub_connect_app/core/storage/local_storage_service.dart';
import 'package:aub_connect_app/data/models/settings_models.dart';
import 'package:aub_connect_app/data/services/settings_service.dart';

class SettingsRepository {
  SettingsRepository(this._settingsService, this._localStorage, this._flags);

  final SettingsService _settingsService;
  final LocalStorageService _localStorage;
  final FeatureFlags _flags;

  bool get useMockApi => _flags.useMockApi;

  Future<UserSettingsModel> loadSettings() async {
    final theme = await _localStorage.readThemeMode();
    final language = await _localStorage.readLanguage();
    final privacy = await _loadLocalPrivacy();
    final notifications = await _loadLocalNotificationPreferences();

    final local = UserSettingsModel(
      themeMode: theme ?? 'light',
      language: language,
      privacy: privacy,
      notifications: notifications,
    );

    if (useMockApi) return local;

    try {
      final remote = await _settingsService.getSettings(
        notificationFallback: notifications,
      );
      await _persistLocal(remote);
      return remote;
    } catch (_) {
      return local;
    }
  }

  Future<PrivacySettings> loadPrivacySettings() async {
    if (useMockApi) return _loadLocalPrivacy();

    try {
      final remote = await _settingsService.getSettings();
      await _localStorage.savePrivacySettings(
        profileVisible: remote.privacy.profileVisible,
        dataSharing: remote.privacy.dataSharing,
        activityTracking: remote.privacy.activityTracking,
      );
      return remote.privacy;
    } catch (_) {
      return _loadLocalPrivacy();
    }
  }

  Future<void> saveThemeMode(String value) async {
    await _localStorage.saveThemeMode(value);
    if (!useMockApi) {
      try {
        await _settingsService.updateSettings({'theme_mode': value});
      } catch (_) {}
    }
  }

  Future<void> saveLanguage(String value) async {
    await _localStorage.saveLanguage(value);
    if (!useMockApi) {
      try {
        await _settingsService.updateSettings({'language': value});
      } catch (_) {}
    }
  }

  Future<void> savePrivacySettings(PrivacySettings settings) async {
    await _localStorage.savePrivacySettings(
      profileVisible: settings.profileVisible,
      dataSharing: settings.dataSharing,
      activityTracking: settings.activityTracking,
    );
    if (!useMockApi) {
      await _settingsService.updateSettings(settings.toJson());
    }
  }

  Future<NotificationPreferences> loadNotificationPreferences() async {
    final local = await _loadLocalNotificationPreferences();
    if (useMockApi) return local;

    try {
      final remote = await _settingsService.getSettings(
        notificationFallback: local,
      );
      await _persistLocalNotificationPreferences(remote.notifications);
      return remote.notifications;
    } catch (_) {
      return local;
    }
  }

  /// Reads the locally cached notification preferences without hitting the
  /// network. Used on hot paths (incoming push) where a remote fetch per
  /// notification would be too expensive.
  Future<NotificationPreferences> loadCachedNotificationPreferences() {
    return _loadLocalNotificationPreferences();
  }

  Future<void> saveNotificationPreferences(
    NotificationPreferences settings,
  ) async {
    if (!useMockApi) {
      await _settingsService.updateSettings(settings.toJson());
    }
    await _persistLocalNotificationPreferences(settings);
  }

  Future<PrivacySettings> _loadLocalPrivacy() async {
    return PrivacySettings(
      profileVisible: await _localStorage.readPrivacyProfileVisible(),
      dataSharing: await _localStorage.readPrivacyDataSharing(),
      activityTracking: await _localStorage.readPrivacyActivityTracking(),
    );
  }

  Future<NotificationPreferences> _loadLocalNotificationPreferences() async {
    final values = await _localStorage.readNotificationPreferences();
    return NotificationPreferences.fromJson(values);
  }

  Future<void> _persistLocalNotificationPreferences(
    NotificationPreferences settings,
  ) {
    return _localStorage.saveNotificationPreferences(
      enabled: settings.allowNotifications,
      chatMessages: settings.chatMessages,
      reminders: settings.reminders,
      announcements: settings.announcements,
      appUpdates: settings.appUpdates,
    );
  }

  Future<void> _persistLocal(UserSettingsModel settings) async {
    await _localStorage.saveThemeMode(settings.themeMode);
    await _localStorage.saveLanguage(settings.language);
    await _localStorage.savePrivacySettings(
      profileVisible: settings.privacy.profileVisible,
      dataSharing: settings.privacy.dataSharing,
      activityTracking: settings.privacy.activityTracking,
    );
    await _persistLocalNotificationPreferences(settings.notifications);
  }
}
