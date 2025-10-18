import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

/// Helper untuk upload image yang PASTI WORK di Web dan Mobile
/// Menggunakan image_picker yang lebih reliable daripada file_picker
class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image dari gallery - WORKS ON WEB AND MOBILE
  static Future<XFile?> pickImageFromGallery() async {
    try {
      print('📸 Opening image picker...');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85, // Compress untuk reduce file size
      );
      
      if (image != null) {
        final size = await image.length();
        print('✅ Image picked: ${image.name}, size: ${(size / 1024).toStringAsFixed(2)} KB');
      } else {
        print('⚠️ No image selected');
      }
      
      return image;
    } catch (e) {
      print('❌ Error picking image: $e');
      rethrow;
    }
  }

  /// Pick image from camera (mobile only, fallback to gallery on web)
  static Future<XFile?> pickImageFromCamera() async {
    try {
      if (kIsWeb) {
        print('⚠️ Camera not available on web, using gallery instead');
        return await pickImageFromGallery();
      }
      
      print('📷 Opening camera...');
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (image != null) {
        final size = await image.length();
        print('✅ Photo taken: ${image.name}, size: ${(size / 1024).toStringAsFixed(2)} KB');
      }
      
      return image;
    } catch (e) {
      print('❌ Error taking photo: $e');
      rethrow;
    }
  }

  /// Convert XFile ke MultipartFile untuk Dio upload
  /// INI YANG PASTI WORK DI WEB DAN MOBILE
  static Future<MultipartFile> toMultipartFile(XFile file) async {
    try {
      print('📤 Converting file to multipart: ${file.name}');
      
      // Baca bytes - ini work di web dan mobile
      final Uint8List bytes = await file.readAsBytes();
      
      print('✅ File ready for upload: ${file.name}, ${bytes.length} bytes');
      
      // Create multipart dari bytes - ALWAYS WORKS
      return MultipartFile.fromBytes(
        bytes,
        filename: file.name,
      );
    } catch (e) {
      print('❌ Error converting to multipart: $e');
      rethrow;
    }
  }

  /// Get image bytes untuk preview atau processing
  static Future<Uint8List> getImageBytes(XFile file) async {
    return await file.readAsBytes();
  }

  /// Get file size dalam format readable
  static Future<String> getReadableFileSize(XFile file) async {
    final bytes = await file.length();
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Validate file size
  static Future<bool> validateFileSize(XFile file, int maxSizeInMB) async {
    final bytes = await file.length();
    final maxBytes = maxSizeInMB * 1024 * 1024;
    
    if (bytes > maxBytes) {
      print('❌ File too large: ${(bytes / 1024 / 1024).toStringAsFixed(2)} MB (max: $maxSizeInMB MB)');
      return false;
    }
    
    return true;
  }
}
