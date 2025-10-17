// Web configuration fallback
// This file provides default values when .env is not available on web

class WebConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://demo-kjavmj.prosesin.id/api', // Ganti dengan URL API Anda
  );

  static const String appName = 'KJAVJM HR App';
  static const String appVersion = '1.0.0';

  // Add other config values as needed
  static const Map<String, String> defaultConfig = {
    'API_BASE_URL': apiBaseUrl,
    'APP_NAME': appName,
    'APP_VERSION': appVersion,
  };
}
