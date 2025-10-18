import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';
import '../config/web_config.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String userName;
  final double size;
  final bool showBorder;
  final VoidCallback? onTap;

  const UserAvatar({
    Key? key,
    this.photoUrl,
    required this.userName,
    this.size = 40,
    this.showBorder = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: showBorder
              ? Border.all(
                  color: AppColors.primary,
                  width: 2,
                )
              : null,
        ),
        child: ClipOval(
          child: _buildAvatarContent(),
        ),
      ),
    );
  }

  Widget _buildAvatarContent() {
    // If no photo URL, show initials
    if (photoUrl == null || photoUrl!.isEmpty) {
      return _buildInitialsAvatar();
    }

    // Build full URL
    String fullUrl = _buildFullUrl(photoUrl!);
    
    print('🖼️ UserAvatar - Platform: ${kIsWeb ? "WEB" : "MOBILE"}');
    print('   Photo URL: $fullUrl');
    
    // PISAHKAN: Web dan Mobile pakai widget berbeda
    if (kIsWeb) {
      return _buildWebImage(fullUrl);
    } else {
      return _buildMobileImage(fullUrl);
    }
  }

  // ✅ MOBILE - Tetap pakai CachedNetworkImage (JANGAN DIUBAH)
  Widget _buildMobileImage(String url) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      httpHeaders: const {
        'Accept': 'image/*',
      },
      placeholder: (context, url) => Container(
        color: AppColors.lightGrey,
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) {
        print('❌ Mobile - Error loading image: $error');
        return _buildInitialsAvatar();
      },
    );
  }

  // 🌐 WEB - Pakai approach berbeda
  Widget _buildWebImage(String url) {
    // Add timestamp untuk bypass cache
    final urlWithTimestamp = url.contains('?') 
        ? '$url&t=${DateTime.now().millisecondsSinceEpoch}'
        : '$url?t=${DateTime.now().millisecondsSinceEpoch}';
    
    print('🌐 Web - Loading: $urlWithTimestamp');
    
    return Image.network(
      urlWithTimestamp,
      fit: BoxFit.cover,
      // CORS headers
      headers: const {
        'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          print('✅ Web - Image loaded successfully');
          return child;
        }
        
        final progress = loadingProgress.expectedTotalBytes != null
            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
            : null;
            
        print('⏳ Web - Loading: ${progress != null ? "${(progress * 100).toStringAsFixed(0)}%" : "..."}');
        
        return Container(
          color: AppColors.lightGrey,
          child: Center(
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Web - Error loading image:');
        print('   Error: $error');
        print('   URL: $url');
        print('   Stack: ${stackTrace?.toString().split('\n').take(3).join('\n')}');
        
        // Fallback ke initials
        return _buildInitialsAvatar();
      },
    );
  }

  String _buildFullUrl(String url) {
    // Already full URL
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return url;
    }
    
    // Relative URL - build full URL
    final baseUrl = WebConfig.apiBaseUrl.replaceAll('/api', '');
    
    // Remove leading slash if exists
    final cleanUrl = url.startsWith('/') ? url.substring(1) : url;
    
    return '$baseUrl/$cleanUrl';
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(userName);
    return Container(
      color: AppColors.primary,
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    
    return name[0].toUpperCase();
  }
}
