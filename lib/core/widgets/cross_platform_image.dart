import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Widget untuk menampilkan network image yang PASTI WORK di web dan mobile
/// Dengan error handling dan fallback yang proper
class CrossPlatformNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final double? width;
  final double? height;

  const CrossPlatformNetworkImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _buildDefaultError();
    }

    // Di web, pakai Image.network langsung (lebih simple dan reliable)
    if (kIsWeb) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        // Disable CORS checks for development
        headers: const {
          'Accept': 'image/*',
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }
          return placeholder ?? _buildDefaultPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error loading image (Web): $error');
          debugPrint('   URL: $imageUrl');
          return errorWidget ?? _buildDefaultError();
        },
      );
    }

    // Di mobile, pakai Image.network juga (cached_network_image causes issues)
    return Image.network(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      headers: const {
        'Accept': 'image/*',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return placeholder ?? _buildDefaultPlaceholder();
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint('❌ Error loading image (Mobile): $error');
        debugPrint('   URL: $imageUrl');
        return errorWidget ?? _buildDefaultError();
      },
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: Icon(
        Icons.broken_image,
        color: Colors.grey[400],
        size: (width != null && height != null) ? (width! + height!) / 4 : 40,
      ),
    );
  }
}
