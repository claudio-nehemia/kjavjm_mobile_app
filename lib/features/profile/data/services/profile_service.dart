import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

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

  Future<Map<String, dynamic>> updatePhoto(PlatformFile file) async {
    try {
      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          file.path!,
          filename: file.name,
        ),
      });

      final response = await _dio.post('/profile/update-photo', data: formData);
      return response.data;
    } catch (e) {
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