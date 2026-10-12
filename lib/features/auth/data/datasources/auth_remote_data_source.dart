import 'package:dio/dio.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<void> logout();
  Future<UserModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  AuthRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      print('🚀 API Call: POST /auth/login');
      print('📍 Base URL: $baseUrl');
      print('📧 Email: $email');
      print('🔒 Password: ${password.isNotEmpty ? '***' : '(empty)'}');
      
      final response = await dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      print('✅ API Success: POST /auth/login');
      print('📦 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Response format dari Laravel: {access_token: "", token_type: "", user: {}}
        if (data['access_token'] != null && data['user'] != null) {
          return UserModel.fromJson(data);
        } else {
          print('❌ Invalid response format: $data');
          throw ServerException(message: 'Invalid response format from server');
        }
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('📍 Full URL: ${e.requestOptions.baseUrl}${e.requestOptions.path}');
      print('📋 Error Status Code: ${e.response?.statusCode}');
      print('📋 Error Response: ${e.response?.data}');
      
      if (e.response?.statusCode == 401) {
        // Extract error message from server response
        final errorMessage = e.response?.data?['message'] ?? 'Email atau password salah';
        throw ServerException(message: errorMessage);
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        String errorMessage = 'Validation error';
        if (errors != null) {
          final firstError = errors.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            errorMessage = firstError.first.toString();
          }
        }
        throw ServerException(message: errorMessage);
      } else if (e.type == DioExceptionType.connectionTimeout ||
                 e.type == DioExceptionType.receiveTimeout ||
                 e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Network connection error');
      } else {
        final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> logout() async {
    try {
      print('🚀 API Call: POST /auth/logout');
      await dio.post('/auth/logout');
      print('✅ API Success: POST /auth/logout');
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Network connection error');
      } else {
        final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Logout failed';
        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      print('🚀 API Call: GET /profile');
      
      final response = await dio.get('/profile');
      
      print('✅ API Success: GET /profile');
      print('📦 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Response format: {message: "", user: {}, statistics: {}}
        if (data['user'] != null) {
          // Merge statistics into the response for UserModel parsing
          return UserModel.fromJson(data);
        } else {
          print('❌ Invalid response format: $data');
          throw ServerException(message: 'Invalid response format from server');
        }
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        throw ServerException(message: 'Server error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'Network connection error');
      } else {
        final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Failed to fetch profile';
        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw ServerException(message: e.toString());
    }
  }
}