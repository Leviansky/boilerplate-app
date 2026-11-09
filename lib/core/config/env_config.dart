enum Environment { development, staging, production }

abstract final class EnvConfig {
  static Environment _currentEnv = _resolveDefaultEnv();

  static Environment _resolveDefaultEnv() {
    const rawEnv = String.fromEnvironment('APP_ENV', defaultValue: 'production');
    switch (rawEnv.toLowerCase()) {
      case 'development':
      case 'dev':
        return Environment.development;
      case 'staging':
      case 'stg':
      case 'stage':
        return Environment.staging;
      case 'production':
      case 'prod':
      default:
        return Environment.production;
    }
  }

  /// Explicitly sets the active environment during bootstrap.
  static void initialize(Environment env) {
    _currentEnv = env;
  }

  static Environment get environment => _currentEnv;

  static bool get isProduction => environment == Environment.production;
  static bool get isStaging => environment == Environment.staging;
  static bool get isDevelopment => environment == Environment.development;

  /// Application title reflecting active flavor
  static String get appName {
    switch (environment) {
      case Environment.development:
        return 'Marketplace Dev';
      case Environment.staging:
        return 'Marketplace Staging';
      case Environment.production:
        return 'Marketplace Enterprise';
    }
  }

  /// Environment-specific backend API Base URL
  static String get baseUrl {
    const definedBaseUrl = String.fromEnvironment('BASE_URL');
    if (definedBaseUrl.isNotEmpty) {
      return definedBaseUrl;
    }

    switch (environment) {
      case Environment.development:
        return 'https://dev-api.marketplace.enterprise.com';
      case Environment.staging:
        return 'https://stg-api.marketplace.enterprise.com';
      case Environment.production:
        return 'https://api.marketplace.enterprise.com';
    }
  }

  static const String _rawApiVersion = String.fromEnvironment('API_VERSION', defaultValue: 'v1');
  static const String _rawAppVersion = String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0');

  static String get apiVersion => _rawApiVersion;
  static String get appVersion => _rawAppVersion;

  /// Logging configuration: detailed logging enabled on Dev & Staging, redacted/disabled on Prod
  static bool get enableDetailedLogging => !isProduction;
}
