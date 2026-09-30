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

  static Future<void> init({String envFileName = '.env'}) async {
    await dotenv.load(fileName: envFileName);
    _instance = AppConfig._fromEnv();
  }

  factory AppConfig._fromEnv() {
    const envFromDefine = String.fromEnvironment('APP_ENV', defaultValue: '');
    final envRaw = envFromDefine.isNotEmpty ? envFromDefine : dotenv.env['APP_ENV'];

    return AppConfig._(
      environment: AppEnvironment.parse(envRaw),
      apiBaseUrl: dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api/v1',
      wsBaseUrl: dotenv.env['WS_BASE_URL'] ?? 'ws://10.0.2.2:8080/ws',
      connectTimeout: Duration(
        seconds: int.tryParse(dotenv.env['API_CONNECT_TIMEOUT_SECONDS'] ?? '') ?? 15,
      ),
      receiveTimeout: Duration(
        seconds: int.tryParse(dotenv.env['API_RECEIVE_TIMEOUT_SECONDS'] ?? '') ?? 30,
      ),
      fcmDebugToken: dotenv.env['FCM_DEBUG_TOKEN']?.trim(),
      googleWebClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim() ?? '',
    );
  }
}
