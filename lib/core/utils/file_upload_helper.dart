import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Helper untuk create MultipartFile yang compatible dengan Web dan Mobile
/// 
/// Di Web: file.path adalah null, harus pakai file.bytes
/// Di Mobile: bisa pakai file.path atau file.bytes
class FileUploadHelper {
  /// Create MultipartFile dari PlatformFile
  /// Compatible untuk Web dan Mobile
  static Future<MultipartFile> createMultipartFile(PlatformFile file) async {
    if (kIsWeb) {
      // Web: Harus pakai bytes karena tidak ada file path
      if (file.bytes == null) {
        throw Exception('File bytes is null on web platform');
      }
      
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      );
    } else {
      // Mobile: Bisa pakai path (lebih efficient) atau bytes
      if (file.path != null) {
        return await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        );
      } else if (file.bytes != null) {
        return MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
        );
      } else {
        throw Exception('File path and bytes are both null');
      }
    }
  }

  /// Helper untuk pick file dengan file_picker
  /// Returns PlatformFile atau null jika cancelled
  static Future<PlatformFile?> pickSingleFile({
    List<String>? allowedExtensions,
    FileType type = FileType.any,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        // PENTING: withData harus true untuk web agar file.bytes terisi
        // Di mobile juga OK pakai true, hanya sedikit lebih lambat
        withData: true, // WAJIB TRUE untuk web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        // Debug log
        if (kIsWeb) {
          print('📦 Web - File picked: ${file.name}, bytes: ${file.bytes?.length ?? 0}');
        } else {
          print('📦 Mobile - File picked: ${file.name}, path: ${file.path}');
        }
        
        return file;
      }
      return null;
    } catch (e) {
      print('❌ Error picking file: $e');
      return null;
    }
  }

  /// Helper untuk pick image file
  static Future<PlatformFile?> pickImage() async {
    return pickSingleFile(
      type: FileType.image,
      allowedExtensions: null, // Accept all image types
    );
  }

  /// Helper untuk pick document (PDF, DOC, etc)
  static Future<PlatformFile?> pickDocument() async {
    return pickSingleFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
    );
  }

  /// Validate file size (in bytes)
  static bool validateFileSize(PlatformFile file, int maxSizeInMB) {
    final maxSizeInBytes = maxSizeInMB * 1024 * 1024;
    final fileSize = file.size;
    
    if (fileSize > maxSizeInBytes) {
      print('❌ File too large: ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB (max: $maxSizeInMB MB)');
      return false;
    }
    return true;
  }

  /// Get file size in human-readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / 1024 / 1024).toStringAsFixed(2)} MB';
    }
  }

  /// Debug info untuk PlatformFile
  static void printFileInfo(PlatformFile file) {
    print('📄 File Info:');
    print('   Name: ${file.name}');
    print('   Size: ${getFileSizeString(file.size)}');
    print('   Extension: ${file.extension}');
    print('   Path: ${file.path ?? "null (web)"}');
    print('   Bytes available: ${file.bytes != null ? "Yes (${file.bytes!.length} bytes)" : "No"}');
    print('   Platform: ${kIsWeb ? "Web" : "Mobile"}');
  }
}
