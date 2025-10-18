// HTTP Client configuration for web platform
// Stub implementation - no configuration needed for web

import 'package:dio/dio.dart';

void configureMobileHttpClient(Dio dio) {
  // Web doesn't need HttpClient configuration
  // Browser handles all HTTP/HTTPS automatically
  print('🌐 Web platform - using browser HTTP client');
}
