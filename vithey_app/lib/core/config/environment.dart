/// Runtime environment derived from `.env` or `--dart-define=APP_ENV=...`.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment parse(String? raw) {
    switch (raw?.toLowerCase().trim()) {
      case 'staging':
      case 'stage':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      default:
        return AppEnvironment.development;
    }
  }

  bool get isDevelopment => this == AppEnvironment.development;
  bool get isProduction => this == AppEnvironment.production;
}
