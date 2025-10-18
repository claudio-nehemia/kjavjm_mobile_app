import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';

/// Helper class untuk handle file upload yang cross-platform (Mobile & Web)
class FileUploadHelper {
  /// Pick image file - works on both mobile and web
  /// Returns PlatformFile with bytes loaded for web compatibility
  static Future<PlatformFile?> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // CRITICAL: Load bytes for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      print('❌ Error picking image: $e');
      return null;
    }
  }

  /// Pick any file - works on both mobile and web
  /// Returns PlatformFile with bytes loaded for web compatibility
  static Future<PlatformFile?> pickFile({
    FileType type = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: type,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
        withData: true, // CRITICAL: Load bytes for web compatibility
      );

      if (result != null && result.files.isNotEmpty) {
        return result.files.first;
      }
      return null;
    } catch (e) {
      print('❌ Error picking file: $e');
      return null;
    }
  }

  /// Convert PlatformFile to MultipartFile for upload
  /// Automatically handles mobile (file path) vs web (bytes) differences
  static Future<MultipartFile> platformFileToMultipart(
    PlatformFile file, {
    String fieldName = 'file',
  }) async {
    if (kIsWeb) {
      // Web: MUST use bytes
      if (file.bytes == null) {
        throw Exception('File bytes not loaded. Use withData: true when picking file.');
      }
      return MultipartFile.fromBytes(
        file.bytes!,
        filename: file.name,
      );
    } else {
      // Mobile: Can use path
      if (file.path == null) {
        throw Exception('File path is null');
      }
      return await MultipartFile.fromFile(
        file.path!,
        filename: file.name,
      );
    }
  }

  /// Create FormData for file upload with additional fields
  static Future<FormData> createFormData(
    PlatformFile file, {
    String fileFieldName = 'file',
    Map<String, dynamic>? additionalFields,
  }) async {
    final multipartFile = await platformFileToMultipart(
      file,
      fieldName: fileFieldName,
    );

    final formDataMap = <String, dynamic>{
      fileFieldName: multipartFile,
    };

    if (additionalFields != null) {
      formDataMap.addAll(additionalFields);
    }

    return FormData.fromMap(formDataMap);
  }

  /// Get file size in human-readable format
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  /// Check if file is image
  static bool isImageFile(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext);
  }

  /// Check if file is document
  static bool isDocumentFile(String filename) {
    final ext = filename.toLowerCase().split('.').last;
    return ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'].contains(ext);
  }

  /// Pick document file - works on both mobile and web
  static Future<PlatformFile?> pickDocument() async {
    return await pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
    );
  }

  /// Validate file size
  /// Returns true if file size is within maxSizeInMB
  static bool validateFileSize(PlatformFile file, int maxSizeInMB) {
    final maxBytes = maxSizeInMB * 1024 * 1024;
    return file.size <= maxBytes;
  }
}
