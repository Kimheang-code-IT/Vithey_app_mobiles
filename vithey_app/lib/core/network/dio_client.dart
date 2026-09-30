import 'package:dio/dio.dart';
import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/storage/secure_storage_service.dart';

class DioClient {
  DioClient(this._secureStorage);

  final SecureStorageService _secureStorage;
  Dio? _dio;

  static const _publicAuthPaths = {
    '/auth/register',
    '/auth/login',
    '/auth/google',
    '/auth/refresh',
    '/auth/forgot-password',
    '/auth/reset-password',
    '/auth/verify-email',
  };

  Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  Dio _createDio() {
    final config = AppConfig.instance;
    final client = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
      ),
    );

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final isPublicAuth = _publicAuthPaths.contains(options.path);
          if (!isPublicAuth) {
            final token = await _secureStorage.readAccessToken();
            if (token != null && token.isNotEmpty && !token.startsWith('mock')) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              !_publicAuthPaths.contains(error.requestOptions.path)) {
            final refreshed = await _tryRefreshToken(client);
            if (refreshed) {
              final request = error.requestOptions;
              final token = await _secureStorage.readAccessToken();
              request.headers['Authorization'] = 'Bearer $token';
              final response = await client.fetch(request);
              handler.resolve(response);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    return client;
  }

  Future<bool> _tryRefreshToken(Dio client) async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty || refreshToken.startsWith('mock')) {
      return false;
    }

    try {
      final response = await client.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data == null) return false;
      await _secureStorage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String? ?? refreshToken,
      );
      return true;
    } catch (_) {
      await _secureStorage.clearTokens();
      return false;
    }
  }
}
