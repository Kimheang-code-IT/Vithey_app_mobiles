import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/core/config/environment.dart';

/// Single source of truth for URLs, timeouts, and environment.
class AppConfig {
  AppConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.wsBaseUrl,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.fcmDebugToken,
    required this.googleWebClientId,
  });

  static AppConfig? _instance;

  static AppConfig get instance {
    final config = _instance;
    if (config == null) {
      throw StateError('AppConfig.init() must be called before accessing instance');
    }
    return config;
  }

  static bool get isInitialized => _instance != null;

  final AppEnvironment environment;
  final String apiBaseUrl;
  final String wsBaseUrl;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final String? fcmDebugToken;

  /// Google Web OAuth client ID used as `serverClientId` for Google Sign-In.
  ///
  /// This is a public client identifier (not a secret); it must match the
  /// audience the backend is configured to accept (`GOOGLE_WEB_CLIENT_ID`).
  final String googleWebClientId;

  /// Loads configuration.
  ///
  /// Resolution order for every value: compile-time `--dart-define` first,
  /// then the bundled `.env` (development convenience), then a safe default.
  /// Loading `.env` is optional: a clean checkout or a release build that
  /// supplies values through `--dart-define` does not need the asset.
  static Future<void> init({String envFileName = '.env'}) async {
    try {
      await dotenv.load(fileName: envFileName);
    } catch (_) {
      // `.env` is a developer convenience only; `--dart-define` or real
      // environment values remain authoritative.
    }
    _instance = AppConfig._fromEnv().._validate();
  }

  factory AppConfig._fromEnv() {
    const defineEnv = String.fromEnvironment('APP_ENV', defaultValue: '');
    const defineApiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    const defineWsBaseUrl = String.fromEnvironment('WS_BASE_URL', defaultValue: '');
    const defineConnect = String.fromEnvironment('API_CONNECT_TIMEOUT_SECONDS', defaultValue: '');
    const defineReceive = String.fromEnvironment('API_RECEIVE_TIMEOUT_SECONDS', defaultValue: '');
    const defineFcmToken = String.fromEnvironment('FCM_DEBUG_TOKEN', defaultValue: '');
    const defineGoogleClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID', defaultValue: '');

    final envRaw = _firstNonEmpty([defineEnv, _env('APP_ENV')]);

    return AppConfig._(
      environment: AppEnvironment.parse(envRaw),
      apiBaseUrl: _firstNonEmpty(
            [defineApiBaseUrl, _env('API_BASE_URL')],
          ) ??
          'http://10.0.2.2:8080/api/v1',
      wsBaseUrl: _firstNonEmpty(
            [defineWsBaseUrl, _env('WS_BASE_URL')],
          ) ??
          'ws://10.0.2.2:8080/ws',
      connectTimeout: Duration(
        seconds: int.tryParse(
              _firstNonEmpty([defineConnect, _env('API_CONNECT_TIMEOUT_SECONDS')]) ?? '',
            ) ??
            15,
      ),
      receiveTimeout: Duration(
        seconds: int.tryParse(
              _firstNonEmpty([defineReceive, _env('API_RECEIVE_TIMEOUT_SECONDS')]) ?? '',
            ) ??
            30,
      ),
      fcmDebugToken: _firstNonEmpty([defineFcmToken, _env('FCM_DEBUG_TOKEN')]),
      googleWebClientId:
          _firstNonEmpty([defineGoogleClientId, _env('GOOGLE_WEB_CLIENT_ID')]) ?? '',
    );
  }

  /// Reads a `.env` value, tolerating an uninitialized/failed dotenv load.
  static String? _env(String key) => dotenv.isInitialized ? dotenv.env[key] : null;

  /// Returns the first non-null, non-empty (after trim) value, else null.
  static String? _firstNonEmpty(List<String?> candidates) {
    for (final candidate in candidates) {
      final value = candidate?.trim();
      if (value != null && value.isNotEmpty) return value;
    }
    return null;
  }

  /// Fails fast on configuration that would silently break a production build.
  void _validate() {
    final apiUri = Uri.tryParse(apiBaseUrl);
    if (apiUri == null || !apiUri.hasScheme || apiUri.host.isEmpty) {
      throw StateError(
        'AppConfig: API_BASE_URL is not a valid absolute URL ("$apiBaseUrl"). '
        'Set it with --dart-define=API_BASE_URL=...',
      );
    }
    if (environment.isProduction) {
      if (apiUri.scheme != 'https') {
        throw StateError(
          'AppConfig: production requires an HTTPS API_BASE_URL, got "$apiBaseUrl". '
          'Release builds disable cleartext traffic.',
        );
      }
      final wsUri = Uri.tryParse(wsBaseUrl);
      if (wsUri != null && wsUri.scheme == 'ws') {
        throw StateError(
          'AppConfig: production requires a secure WS_BASE_URL (wss://), got "$wsBaseUrl".',
        );
      }
    }
  }
}
