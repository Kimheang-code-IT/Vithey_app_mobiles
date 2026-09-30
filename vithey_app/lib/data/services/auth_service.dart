import 'package:aub_connect_app/core/constants/api_endpoints.dart';
import 'package:aub_connect_app/core/network/api_response.dart';
import 'package:aub_connect_app/core/network/api_service.dart';
import 'package:aub_connect_app/data/models/auth_result_model.dart';
import 'package:aub_connect_app/data/models/auth_token_model.dart';
import 'package:aub_connect_app/data/models/user_model.dart';

class AuthService {
  AuthService(this._api);

  final ApiService _api;

  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.authLogin,
      data: {'email_or_phone': email, 'password': password},
      fromJson: (json) => AuthResultModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(_formatError(response.error, 'Login failed'));
    }
    return response.data!;
  }

  Future<AuthResultModel> googleLogin({required String idToken}) async {
    final response = await _api.post(
      ApiEndpoints.authGoogle,
      data: {'id_token': idToken},
      fromJson: (json) => AuthResultModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(_formatError(response.error, 'Google sign-in failed'));
    }
    return response.data!;
  }

  String _formatError(ApiError? error, String fallback) {
    if (error == null) return fallback;
    final details = error.details;
    if (details is List && details.isNotEmpty) {
      final first = details.first;
      if (first is Map && first['message'] != null) {
        return first['message'].toString();
      }
    }
    return error.message.isNotEmpty ? error.message : fallback;
  }

  Future<AuthResultModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _api.post(
      ApiEndpoints.authRegister,
      data: {
        'full_name': fullName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': 'USER',
      },
      fromJson: (json) => AuthResultModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(_formatError(response.error, 'Registration failed'));
    }
    return response.data!;
  }

  /// Auth identity (`GET /auth/me`) — includes `is_student_verified`.
  Future<UserModel> getMe() async {
    final response = await _api.get(
      ApiEndpoints.authMe,
      fromJson: (json) => UserModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(response.error?.message ?? 'Failed to load profile');
    }
    return response.data!;
  }

  Future<void> logout({required String refreshToken}) async {
    final response = await _api.post<void>(
      ApiEndpoints.authLogout,
      data: {'refresh_token': refreshToken},
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw AuthServiceException(response.error?.message ?? 'Logout failed');
    }
  }

  Future<AuthTokenModel> refresh({required String refreshToken}) async {
    final response = await _api.post<AuthTokenModel>(
      ApiEndpoints.authRefresh,
      data: {'refresh_token': refreshToken},
      fromJson: (json) => AuthTokenModel.fromJson(json as Map<String, dynamic>),
    );
    if (!response.isSuccess || response.data == null) {
      throw AuthServiceException(response.error?.message ?? 'Token refresh failed');
    }
    return response.data!;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _api.patch(
      ApiEndpoints.authChangePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
      fromJson: (_) => null,
    );
    if (!response.isSuccess) {
      throw AuthServiceException(response.error?.message ?? 'Password change failed');
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    final response = await _api.post<void>(
      ApiEndpoints.authForgotPassword,
      data: {'email': email},
      fromJson: (_) {},
    );
    if (!response.isSuccess) {
      throw AuthServiceException(response.error?.message ?? 'Could not send reset link');
    }
  }
}

class AuthServiceException implements Exception {
  AuthServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
