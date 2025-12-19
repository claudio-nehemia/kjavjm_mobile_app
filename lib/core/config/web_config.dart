// Web configuration fallback
// This file provides default values when .env is not available on web

import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebConfig {
  // DEVELOPMENT: Use localhost for testing
  // PRODUCTION: Use production URL
  // static const String defaultApiBaseUrl = 'http://localhost:8000/api';
  static const String defaultApiBaseUrl = 'https://internal.kantorjasaakuntanvmjpapua.com/api';
  
  static const String appName = 'KJAVJM HR App';
  static const String appVersion = '1.0.0';

  /// Get BASE_URL with fallback
  /// Prioritas: dart-define > .env > default
  static String get apiBaseUrl {
    // Try dart-define first (from build command)
    const defineUrl = String.fromEnvironment('BASE_URL', defaultValue: '');
    if (defineUrl.isNotEmpty) {
      return defineUrl;
    }
    
    // Try dotenv (akan fail di web kalau .env tidak ada)
    try {
      final envUrl = dotenv.env['BASE_URL'];
      if (envUrl != null && envUrl.isNotEmpty) {
        return envUrl;
      }
    } catch (e) {
      // Ignore error jika dotenv belum di-load atau tidak tersedia
    }
    
    // Fallback ke default
    return defaultApiBaseUrl;
  }

  // Add other config values as needed
  static Map<String, String> get defaultConfig => {
    'BASE_URL': apiBaseUrl,
    'APP_NAME': appName,
    'APP_VERSION': appVersion,
  };
}
