import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/settings_models.dart';

class SettingsService {
  SettingsService(this._api);

  final ApiService _api;

  Future<UserSettingsModel> getSettings({
    NotificationPreferences notificationFallback =
        const NotificationPreferences(),
  }) async {
    final response = await _api.get(
      ApiEndpoints.usersMeSettings,
      fromJson: (json) => UserSettingsModel.fromJson(
        json as Map<String, dynamic>,
        notificationFallback: notificationFallback,
      ),
    );
    if (!response.isSuccess || response.data == null) {
      throw SettingsServiceException(
          response.error?.message ?? 'Failed to load settings');
    }
    return response.data!;
  }

  Future<UserSettingsModel> updateSettings(Map<String, dynamic> data) async {
    final response = await _api.patch(
      ApiEndpoints.usersMeSettings,
      data: data,
      fromJson: (json) =>
          UserSettingsModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw SettingsServiceException(
          response.error?.message ?? 'Failed to save settings');
    }
    return response.data!;
  }
}

class SettingsServiceException implements Exception {
  SettingsServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
