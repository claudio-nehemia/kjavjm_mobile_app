import 'package:flutter/material.dart';

/// Stub untuk mobile - tidak digunakan di mobile
/// Hanya untuk conditional import agar tidak error
class WebImageWidget extends StatelessWidget {
  final String imageUrl;
  final double size;
  final VoidCallback? onError;

  const WebImageWidget({
    Key? key,
    required this.imageUrl,
    required this.size,
    this.onError,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Di mobile, widget ini tidak pernah dipanggil
    // Karena ada kIsWeb check di parent
    return Container(
      width: size,
      height: size,
      color: Colors.grey,
      child: const Center(
        child: Text('Mobile Stub'),
      ),
    );
  }
}
