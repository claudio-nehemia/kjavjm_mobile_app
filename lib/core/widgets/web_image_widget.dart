import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
// ignore: avoid_web_libraries_in_flutter
import 'dart:ui_web' as ui_web;

/// Widget khusus untuk display image di web yang bypass CORS
/// Menggunakan HTML <img> tag native
class WebImageWidget extends StatefulWidget {
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
  State<WebImageWidget> createState() => _WebImageWidgetState();
}

class _WebImageWidgetState extends State<WebImageWidget> {
  late String viewType;
  bool _hasError = false;

  static final Set<String> _registeredViewTypes = <String>{};

  @override
  void initState() {
    super.initState();
    viewType = 'web-image-${widget.imageUrl.hashCode}';
    _registerImageView();
  }

  void _registerImageView() {
    if (!kIsWeb) return;

    // Register view factory untuk HtmlElementView
    // ignore: undefined_prefixed_name
    if (_registeredViewTypes.contains(viewType)) {
      // Already registered for this viewType, skip re-registration
      return;
    }

    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final img = html.ImageElement()
          ..src = widget.imageUrl
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.objectFit = 'cover'
          ..style.border = 'none';
          // NOTE: Jangan set crossOrigin by default.
          // Pada lokal (http://localhost:8000) sering tidak ada header CORS,
          // jika kita set crossOrigin='anonymous', browser akan memblokir load.
          // Jika butuh CORS-enabled image untuk use-case canvas, pertimbangkan
          // menambahkan opsi khusus, tapi default-nya dibiarkan kosong agar
          // <img> tetap bisa menampilkan gambar meski beda origin.

        // Handle image load error
        img.onError.listen((event) {
          print('❌ WebImageWidget - Failed to load: ${widget.imageUrl}');
          if (mounted) {
            setState(() {
              _hasError = true;
            });
            widget.onError?.call();
          }
        });

        // Handle image load success
        img.onLoad.listen((event) {
          print('✅ WebImageWidget - Loaded successfully: ${widget.imageUrl}');
        });

        return img;
      },
    );

    _registeredViewTypes.add(viewType);
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Container(
        width: widget.size,
        height: widget.size,
        color: Colors.grey[300],
        child: Icon(
          Icons.broken_image,
          color: Colors.grey[600],
          size: widget.size * 0.5,
        ),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: HtmlElementView(
        viewType: viewType,
      ),
    );
  }
}
