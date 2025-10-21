// HTTP Client configuration for web platform
// Configure Dio to use browser's fetch API with CORS support

import 'package:dio/dio.dart';
import 'package:dio/browser.dart';

void configureMobileHttpClient(Dio dio) {
  // Use BrowserHttpClientAdapter for proper CORS handling
  dio.httpClientAdapter = BrowserHttpClientAdapter(
    withCredentials: false, // Set true jika butuh cookies/auth credentials
  );
  
  print('🌐 Web platform - using browser HTTP client with CORS support');
}
