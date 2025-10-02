import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/app_colors.dart';

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
    // If photo URL is provided and not empty
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: AppColors.lightGrey,
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildInitialsAvatar(),
      );
    }

    // Default to initials avatar
    return _buildInitialsAvatar();
  }

  Widget _buildInitialsAvatar() {
    final initials = _getInitials(userName);
    final color = _getColorFromName(userName);

    return Container(
      color: color.withOpacity(0.2),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: color,
            fontSize: size * 0.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';

    final parts = name.trim().split(' ');
    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    }

    return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1))
        .toUpperCase();
  }

  Color _getColorFromName(String name) {
    // Generate color based on name hash
    final hash = name.hashCode;
    final colors = [
      AppColors.primary,
      AppColors.secondary,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
    ];

    return colors[hash.abs() % colors.length];
  }
}
