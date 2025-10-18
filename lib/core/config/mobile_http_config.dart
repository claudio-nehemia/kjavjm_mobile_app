// HTTP Client configuration for mobile platforms only
// This file should NOT be imported on web

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'dart:io';

void configureMobileHttpClient(Dio dio) {
  // Add SSL certificate handling for self-signed certificates
  // IMPORTANT: In production, use proper SSL certificates
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    // Allow self-signed certificates in all modes
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      print('🔒 SSL Certificate check for: $host:$port');
      // Accept all certificates for development/testing
      // In production, verify the certificate properly
      return true;
    };
    // Disable certificate verification completely for development
    return client;
  };
  
  // Set onHttpClientCreate to ensure it's used
  (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      print('🔒 SSL Certificate check (onCreate) for: $host:$port');
      return true;
    };
    return client;
  };
}
