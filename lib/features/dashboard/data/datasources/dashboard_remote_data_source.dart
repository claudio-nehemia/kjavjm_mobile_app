import 'package:dio/dio.dart';
import '../models/dashboard_data_model.dart';
import '../../../attendance/data/models/attendance_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataModel> getDashboardData();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      print('🚀 API Call: GET /dashboard');
      
      final response = await dio.get('/dashboard');
      
      print('✅ API Success: GET /dashboard');
      print('📦 Response Data: ${response.data}');
      
      if (response.statusCode == 200) {
        // Fetch today's attendance separately
        TodayAttendanceModel? todayAttendance;
        try {
          print('🚀 API Call: GET /attendance/today');
          final attendanceResponse = await dio.get('/attendance/today');
          print('✅ API Success: GET /attendance/today');
          print('📦 Attendance Response Data: ${attendanceResponse.data}');
          
          if (attendanceResponse.statusCode == 200) {
            todayAttendance = TodayAttendanceModel.fromJson(attendanceResponse.data);
          }
        } catch (e) {
          print('⚠️ Failed to fetch today attendance: $e');
          // Continue without today's attendance if it fails
        }
        
        // Merge today's attendance into dashboard data
        final dashboardJson = Map<String, dynamic>.from(response.data);
        if (todayAttendance != null) {
          dashboardJson['today_attendance'] = todayAttendance.toJson();
        }
        
        return DashboardDataModel.fromJson(dashboardJson);
      } else {
        print('❌ API Error: Status ${response.statusCode}');
        throw ServerException(message: 'Server returned status ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('📋 Error Details: ${e.response?.data}');
      
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw NetworkException(message: 'Connection timeout');
      } else if (e.type == DioExceptionType.connectionError) {
        throw NetworkException(message: 'No internet connection');
      } else {
        final errorMessage = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
        throw ServerException(message: errorMessage);
      }
    } catch (e) {
      print('❌ Unexpected Error: $e');
      throw ServerException(message: e.toString());
    }
  }
}