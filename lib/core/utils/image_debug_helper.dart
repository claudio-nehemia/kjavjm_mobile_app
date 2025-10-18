import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/web_config.dart';

/// Debug helper untuk check apakah image URL dari server bisa diakses
class ImageDebugHelper {
  static Future<void> checkImageUrl(String? photoUrl) async {
    if (photoUrl == null || photoUrl.isEmpty) {
      debugPrint('⚠️ Photo URL is null or empty');
      return;
    }

    // Build full URL
    String fullUrl = photoUrl;
    if (!photoUrl.startsWith('http://') && !photoUrl.startsWith('https://')) {
      final baseUrl = WebConfig.apiBaseUrl.replaceAll('/api', '');
      fullUrl = '$baseUrl/$photoUrl';
    }

    debugPrint('🔍 Checking image URL: $fullUrl');

    try {
      final dio = Dio();
      final response = await dio.head(
        fullUrl,
        options: Options(
          followRedirects: true,
          validateStatus: (status) => status! < 500,
          headers: {
            'Accept': 'image/*',
          },
        ),
      );

      debugPrint('✅ Image URL accessible:');
      debugPrint('   Status: ${response.statusCode}');
      debugPrint('   Content-Type: ${response.headers.value('content-type')}');
      debugPrint('   Content-Length: ${response.headers.value('content-length')}');
      
      // Check CORS headers
      final corsOrigin = response.headers.value('access-control-allow-origin');
      final corsHeaders = response.headers.value('access-control-allow-headers');
      
      if (corsOrigin != null) {
        debugPrint('   CORS Origin: $corsOrigin');
      } else {
        debugPrint('   ⚠️ No CORS headers (might cause issues on web)');
      }
      
      if (corsHeaders != null) {
        debugPrint('   CORS Headers: $corsHeaders');
      }

    } catch (e) {
      debugPrint('❌ Error checking image URL: $e');
      
      if (e is DioException) {
        debugPrint('   Status Code: ${e.response?.statusCode}');
        debugPrint('   Response: ${e.response?.data}');
      }
    }
  }

  /// Test apakah image bisa di-load dengan Image.network
  static Widget testImageWidget(String photoUrl) {
    String fullUrl = photoUrl;
    if (!photoUrl.startsWith('http://') && !photoUrl.startsWith('https://')) {
      final baseUrl = WebConfig.apiBaseUrl.replaceAll('/api', '');
      fullUrl = '$baseUrl/$photoUrl';
    }

    debugPrint('🧪 Testing image widget with URL: $fullUrl');

    return Image.network(
      fullUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          debugPrint('✅ Image loaded successfully in test widget');
          return child;
        }
        return CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
              : null,
        );
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Image failed to load in test widget:');
        debugPrint('   Error: $error');
        return Container(
          color: Colors.red[100],
          child: const Icon(Icons.error, color: Colors.red),
        );
      },
    );
  }
}
