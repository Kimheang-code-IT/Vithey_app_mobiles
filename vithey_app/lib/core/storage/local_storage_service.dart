import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _themeKey = 'theme_mode';
  static const _languageKey = 'language';
  static const _languageSelectedKey = 'language_selected';
  static const _onboardingKey = 'onboarding_completed';
  static const _startupKey = 'startup_completed';
  static const _verificationStatusKey = 'verification_status';
  static const _verificationStudentIdKey = 'verification_student_id';
  static const _verificationEmailKey = 'verification_email';
  static const _verificationSubmittedAtKey = 'verification_submitted_at';
  static const _verificationDocumentKey = 'verification_document_file_name';
  static const _privacyProfileVisibleKey = 'privacy_profile_visible';
  static const _privacyDataSharingKey = 'privacy_data_sharing';
  static const _privacyActivityTrackingKey = 'privacy_activity_tracking';
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _notificationsChatKey = 'notifications_chat_messages';
  static const _notificationsRemindersKey = 'notifications_reminders';
  static const _notificationsAnnouncementsKey = 'notifications_announcements';
  static const _notificationsAppUpdatesKey = 'notifications_app_updates';
  static const _chatFoldersKey = 'chat_folders_json';
  static const _mutedConversationsKey = 'muted_chat_conversations';
  static const _mockDeletedPostIdsKey = 'mock_deleted_post_ids';
  static const _mockAppliedJobIdsKey = 'mock_applied_job_ids';
  static const _mockApplicationStatusesKey = 'mock_application_statuses_json';
  static const _mockSubmittedApplicationsKey = 'mock_submitted_applications_json';
  static const _mockCatalogRestoredKey = 'mock_catalog_restored_v1';

  Future<void> saveMockDeletedPostIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final ok = await prefs.setStringList(_mockDeletedPostIdsKey, ids.toList());
    if (!ok) {
      throw StateError('Failed to persist mock deleted post ids');
    }
  }

  Future<void> clearMockDeletedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_mockDeletedPostIdsKey);
  }

  /// One-shot restore of the full mock catalog after wiping demo deletes.
  Future<bool> consumeMockCatalogRestore() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_mockCatalogRestoredKey) == true) return false;
    await prefs.remove(_mockDeletedPostIdsKey);
    await prefs.setBool(_mockCatalogRestoredKey, true);
    return true;
  }

  Future<Set<String>> readMockDeletedPostIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    return prefs.getStringList(_mockDeletedPostIdsKey)?.toSet() ?? {};
  }

  Future<Set<String>> readMockAppliedJobIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_mockAppliedJobIdsKey)?.toSet() ?? {};
  }

  Future<void> saveMockAppliedJobIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_mockAppliedJobIdsKey, ids.toList());
  }

  Future<Map<String, String>> readMockApplicationStatuses() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mockApplicationStatusesKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  Future<void> saveMockApplicationStatuses(Map<String, String> statuses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mockApplicationStatusesKey, jsonEncode(statuses));
  }

  Future<List<Map<String, dynamic>>> readMockSubmittedApplications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mockSubmittedApplicationsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> saveMockSubmittedApplications(
    List<Map<String, dynamic>> applications,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _mockSubmittedApplicationsKey,
      jsonEncode(applications),
    );
  }

  Future<Set<String>> readMutedConversationIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_mutedConversationsKey)?.toSet() ?? {};
  }

  Future<bool> isConversationMuted(String conversationId) async {
    final ids = await readMutedConversationIds();
    return ids.contains(conversationId);
  }

  Future<void> setConversationMuted(String conversationId, bool muted) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await readMutedConversationIds();
    if (muted) {
      ids.add(conversationId);
    } else {
      ids.remove(conversationId);
    }
    await prefs.setStringList(_mutedConversationsKey, ids.toList());
  }

  Future<String?> readChatFoldersJson() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chatFoldersKey);
  }

  Future<void> saveChatFoldersJson(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chatFoldersKey, json);
  }

  Future<String?> readThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, value);
  }

  Future<String> readLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> saveLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, value);
  }

  /// True after the user has completed Select Language.
  Future<bool> isLanguageSelected() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_languageSelectedKey) ?? false;
  }

  Future<void> setLanguageSelected(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_languageSelectedKey, value);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, value);
  }

  Future<bool> isStartupCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_startupKey) ?? false;
  }

  Future<void> setStartupCompleted(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_startupKey, value);
  }

  Future<String?> readVerificationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_verificationStatusKey);
  }

  Future<void> saveVerificationStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationStatusKey, status);
  }

  Future<void> saveVerificationDraft({
    required String studentId,
    required String universityEmail,
    required String submittedAtIso,
    String? documentFileName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_verificationStudentIdKey, studentId);
    await prefs.setString(_verificationEmailKey, universityEmail);
    await prefs.setString(_verificationSubmittedAtKey, submittedAtIso);
    if (documentFileName != null && documentFileName.isNotEmpty) {
      await prefs.setString(_verificationDocumentKey, documentFileName);
    } else {
      await prefs.remove(_verificationDocumentKey);
    }
  }

  Future<void> clearVerificationDocument() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verificationDocumentKey);
  }

  Future<Map<String, String?>> readVerificationDraft() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'studentId': prefs.getString(_verificationStudentIdKey),
      'universityEmail': prefs.getString(_verificationEmailKey),
      'submittedAt': prefs.getString(_verificationSubmittedAtKey),
      'documentFileName': prefs.getString(_verificationDocumentKey),
    };
  }

  Future<void> clearVerificationData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_verificationStatusKey);
    await prefs.remove(_verificationStudentIdKey);
    await prefs.remove(_verificationEmailKey);
    await prefs.remove(_verificationSubmittedAtKey);
    await prefs.remove(_verificationDocumentKey);
  }

  Future<bool> readPrivacyProfileVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyProfileVisibleKey) ?? true;
  }

  Future<bool> readPrivacyDataSharing() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyDataSharingKey) ?? false;
  }

  Future<bool> readPrivacyActivityTracking() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_privacyActivityTrackingKey) ?? false;
  }

  Future<void> savePrivacySettings({
    bool? profileVisible,
    bool? dataSharing,
    bool? activityTracking,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (profileVisible != null) {
      await prefs.setBool(_privacyProfileVisibleKey, profileVisible);
    }
    if (dataSharing != null) {
      await prefs.setBool(_privacyDataSharingKey, dataSharing);
    }
    if (activityTracking != null) {
      await prefs.setBool(_privacyActivityTrackingKey, activityTracking);
    }
  }

  Future<bool> readBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<void> saveBiometricEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, value);
  }

  Future<Map<String, bool>> readNotificationPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_notificationsEnabledKey) ?? true,
      'chat_messages': prefs.getBool(_notificationsChatKey) ?? true,
      'reminders': prefs.getBool(_notificationsRemindersKey) ?? true,
      'announcements': prefs.getBool(_notificationsAnnouncementsKey) ?? false,
      'app_updates': prefs.getBool(_notificationsAppUpdatesKey) ?? true,
    };
  }

  Future<void> saveNotificationPreferences({
    required bool enabled,
    required bool chatMessages,
    required bool reminders,
    required bool announcements,
    required bool appUpdates,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setBool(_notificationsEnabledKey, enabled),
      prefs.setBool(_notificationsChatKey, chatMessages),
      prefs.setBool(_notificationsRemindersKey, reminders),
      prefs.setBool(_notificationsAnnouncementsKey, announcements),
      prefs.setBool(_notificationsAppUpdatesKey, appUpdates),
    ]);
  }

  Future<void> clearSessionPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_startupKey);
  }
}
