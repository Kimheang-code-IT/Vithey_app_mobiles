import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:aub_connect_app/core/config/app_config.dart';
import 'package:aub_connect_app/core/config/environment.dart';

/// Central feature flags — repositories must read mock/real mode from here only.
///
/// Live API is the default. Mocks are opt-in via `USE_MOCK_*=true` and are
/// hard-disabled in production builds.
class FeatureFlags {
  FeatureFlags({AppConfig? config}) : _config = config ?? AppConfig.instance;

  final AppConfig _config;

  static bool _isFalse(String? value) => value?.toLowerCase() == 'false';
  static bool _isTrue(String? value) => value?.toLowerCase() == 'true';

  /// Global API mock. Opt-in only (`USE_MOCK_API=true`). Off in production.
  bool get useMockApi =>
      !isProduction && _isTrue(dotenv.env['USE_MOCK_API']);

  bool get useMockAuth =>
      !isProduction &&
      (_isTrue(dotenv.env['USE_MOCK_AUTH']) || useMockApi);

  bool get useMockAi {
    if (isProduction) return false;
    final mockAi = dotenv.env['USE_MOCK_AI'];
    if (mockAi != null) return _isTrue(mockAi);
    return useMockApi;
  }

  bool get useMockSearch {
    if (isProduction) return false;
    final mockSearch = dotenv.env['USE_MOCK_SEARCH'];
    if (mockSearch != null) return _isTrue(mockSearch);
    return useMockApi;
  }

  bool get useMockChat =>
      !isProduction &&
      (_isTrue(dotenv.env['USE_MOCK_CHAT']) || useMockApi);

  bool get useMockNotifications =>
      !isProduction &&
      (_isTrue(dotenv.env['USE_MOCK_NOTIFICATIONS']) || useMockApi);

  bool get useMockMap {
    if (isProduction) return false;
    final mockMap = dotenv.env['USE_MOCK_MAP'];
    if (mockMap != null) return _isTrue(mockMap);
    return useMockApi;
  }

  /// AI product flags (backed by `ai_core`). Default ON; set `USE_AI_*=false`
  /// to hide the UI. These are real backend features, so they stay enabled in
  /// production.
  bool get useAiCv => !_isFalse(dotenv.env['USE_AI_CV']);

  bool get useAiFeed => !_isFalse(dotenv.env['USE_AI_FEED']);

  bool get useAiSkills => !_isFalse(dotenv.env['USE_AI_SKILLS']);

  bool get useAiJobMatch => !_isFalse(dotenv.env['USE_AI_JOB_MATCH']);

  bool get enableGoogleAuth => _isTrue(dotenv.env['ENABLE_GOOGLE_AUTH']);

  bool get fcmEnabled => _isTrue(dotenv.env['FCM_ENABLED']);

  bool get useRealApi => !useMockApi;

  bool get isProduction => _config.environment.isProduction;

  /// Demo-only controls — only when mocks are explicitly on.
  bool get showMockDevTools => !isProduction && useMockApi;

  bool get forceShowOnboarding =>
      !isProduction && _isTrue(dotenv.env['FORCE_SHOW_ONBOARDING']);

  bool get forceShowStartup =>
      !isProduction && _isTrue(dotenv.env['FORCE_SHOW_STARTUP']);

  bool get forceDevFunnel =>
      !isProduction && _isTrue(dotenv.env['FORCE_DEV_FUNNEL']);

  AppEnvironment get environment => _config.environment;
}
