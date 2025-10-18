                                                         import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/utils/image_upload_helper.dart';

class ProfileService {
  final Dio _dio;
  
  ProfileService(this._dio);

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
  }) async {
    try {
      final response = await _dio.put('/profile/update', data: {
        'name': name,
        'phone': phone,
        'address': address,
        'city': city,
        'postal_code': postalCode,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  /// Update photo - WORKS ON WEB AND MOBILE
  Future<Map<String, dynamic>> updatePhoto(XFile file) async {
    try {
      final size = await ImageUploadHelper.getReadableFileSize(file);
      print('📸 Uploading photo: ${file.name}, Size: $size');
      
      // Convert ke multipart - PASTI WORK
      final multipartFile = await ImageUploadHelper.toMultipartFile(file);
      
      final formData = FormData.fromMap({
        'photo': multipartFile,
      });

      print('📤 Sending photo to server...');
      final response = await _dio.post('/profile/update-photo', data: formData);
      
      print('✅ Photo uploaded successfully');
      return response.data;
    } catch (e) {
      print('❌ Error updating photo: $e');
      throw Exception('Failed to update photo: $e');
    }
  }

  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.put('/profile/change-password', data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });
      return response.data;
    } catch (e) {
      throw Exception('Failed to change password: $e');
    }
  }
}