import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/error/exceptions.dart';
import '../models/attendance_model.dart';
import '../models/leave_approval_model.dart';
import '../models/attendance_statistics_model.dart';
import '../models/monthly_statistics_model.dart';
import '../models/attendance_history_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<TodayAttendanceModel> getTodayAttendance();
  Future<AttendanceModel> checkIn(String status, String? documentation);
  Future<AttendanceModel> checkInWithLeave({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    required PlatformFile document,
  });
  Future<AttendanceModel> checkOut();
  Future<AttendanceModel> checkOutWithOvertime(String reason, String? notes);
  Future<List<AttendanceModel>> getAttendanceHistory(String month);
  Future<LeaveApprovalModel> submitLeaveRequest({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    String? document,
  });
  Future<List<AttendanceModel>> getRecentAttendance();
  Future<AttendanceStatisticsModel> getAttendanceStatistics(String year);
  Future<List<MonthlyStatisticsModel>> getMonthlyStatistics(String year);
  Future<AttendanceHistoryModel> getDetailedHistory({
    int limit = 10,
    int page = 1,
    String? status,
    String? month,
    String? startDate,
    String? endDate,
  });
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  AttendanceRemoteDataSourceImpl({
    required this.dio,
    required this.sharedPreferences,
  });

  String get baseUrl => dotenv.env['BASE_URL'] ?? 'http://192.168.22.146:8000/api';

  Future<String?> get authToken async {
    return sharedPreferences.getString('auth_token');
  }

  @override
  Future<TodayAttendanceModel> getTodayAttendance() async {
    try {
      final token = await authToken;
      final response = await dio.get(
        '$baseUrl/attendance/today',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        print('DEBUG - Raw API response: ${response.data}');
        return TodayAttendanceModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to get today attendance');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<AttendanceModel> checkIn(String status, String? documentation) async {
    try {
      final token = await authToken;
      final response = await dio.post(
        '$baseUrl/attendance/check-in',
        data: {
          'status': status,
          if (documentation != null) 'documentation': documentation,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return AttendanceModel.fromJson(response.data['data']);
      } else {
        throw ServerException(message: 'Failed to check in');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Handle validation error from server
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Validation error';
        throw ServerException(message: message);
      } else if (e.response?.statusCode == 409) {
        // Handle conflict error (already checked in)
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Conflict error';
        throw ServerException(message: message);
      } else {
        throw ServerException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<AttendanceModel> checkInWithLeave({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    required PlatformFile document,
  }) async {
    try {
      final token = await authToken;
      
      // Create multipart form data
      FormData formData = FormData.fromMap({
        'status': 'leave',
        'leave_reason': leaveReason,
        'start_date': startDate,
        'end_date': endDate,
        'total_days': totalDays,
        'type': type,
        'document': await MultipartFile.fromFile(
          document.path!,
          filename: document.name,
        ),
      });

      final response = await dio.post(
        '$baseUrl/attendance/check-in',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        return AttendanceModel.fromJson(response.data['data']);
      } else {
        throw ServerException(message: 'Failed to check in with leave');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Handle validation error from server
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Validation error';
        throw ServerException(message: message);
      } else if (e.response?.statusCode == 409) {
        // Handle conflict error (already checked in)
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Conflict error';
        throw ServerException(message: message);
      } else {
        throw ServerException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<AttendanceModel> checkOut() async {
    try {
      final token = await authToken;
      final response = await dio.post(
        '$baseUrl/attendance/check-out',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final attendanceModel = AttendanceModel.fromJson(response.data['data']);
        
        // Store overtime info if available for later use
        if (response.data['is_overtime'] == true) {
          // You can handle overtime notification here or pass it through a different mechanism
          print('Overtime detected: ${response.data['overtime_info']}');
        }
        
        return attendanceModel;
      } else {
        throw ServerException(message: 'Failed to check out');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Handle validation error from server
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Validation error';
        throw ServerException(message: message);
      } else if (e.response?.statusCode == 409) {
        // Handle conflict error (already checked out)
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Conflict error';
        throw ServerException(message: message);
      } else {
        throw ServerException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<AttendanceModel> checkOutWithOvertime(String reason, String? notes) async {
    try {
      final token = await authToken;
      final response = await dio.post(
        '$baseUrl/attendance/check-out',
        data: {
          'overtime_reason': reason,
          if (notes != null && notes.isNotEmpty) 'overtime_notes': notes,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final attendanceModel = AttendanceModel.fromJson(response.data['data']);
        
        // Store overtime info if available for later use
        if (response.data['is_overtime'] == true) {
          print('Overtime created: ${response.data['overtime_info']}');
        }
        
        return attendanceModel;
      } else {
        throw ServerException(message: 'Failed to check out with overtime');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Validation error';
        throw ServerException(message: message);
      } else if (e.response?.statusCode == 409) {
        final errorData = e.response?.data;
        final message = errorData?['message'] ?? 'Conflict error';
        throw ServerException(message: message);
      } else {
        throw ServerException(message: 'Network error: ${e.message}');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getAttendanceHistory(String month) async {
    try {
      final token = await authToken;
      final response = await dio.get(
        '$baseUrl/attendance/history',
        queryParameters: {'month': month},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // API returns array directly, not wrapped in 'data' field
        final List<dynamic> data = response.data;
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to get attendance history');
      }
    } catch (e) {
      throw ServerException(message: 'Eror nih bang: $e');
    }
  }

  @override
  Future<LeaveApprovalModel> submitLeaveRequest({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    String? document,
  }) async {
    try {
      final token = await authToken;
      final response = await dio.post(
        '$baseUrl/attendance/leave-data',
        data: {
          'leave_reason': leaveReason,
          'start_date': startDate,
          'end_date': endDate,
          'total_days': totalDays,
          'type': type,
          if (document != null) 'document': document,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        return LeaveApprovalModel.fromJson(response.data['data']);
      } else {
        throw ServerException(message: 'Failed to submit leave request');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<AttendanceModel>> getRecentAttendance() async {
    try {
      final token = await authToken;
      final response = await dio.get(
        '$baseUrl/attendance/history',
        queryParameters: {'limit': 3},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // API returns array directly, not wrapped in 'data' field
        final List<dynamic> data = response.data;
        return data.map((json) => AttendanceModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to get recent attendance');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<AttendanceStatisticsModel> getAttendanceStatistics(String year) async {
    try {
      final token = await authToken;
      final response = await dio.get(
        '$baseUrl/attendance/statistics',
        queryParameters: {'year': year},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AttendanceStatisticsModel.fromJson(response.data['yearly_stats']);
      } else {
        throw ServerException(message: 'Failed to get attendance statistics');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<List<MonthlyStatisticsModel>> getMonthlyStatistics(String year) async {
    try {
      final token = await authToken;
      final response = await dio.get(
        '$baseUrl/attendance/statistics',
        queryParameters: {'year': year},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> monthlyData = response.data['monthly_stats'];
        return monthlyData.map((json) => MonthlyStatisticsModel.fromJson(json)).toList();
      } else {
        throw ServerException(message: 'Failed to get monthly statistics');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }

  @override
  Future<AttendanceHistoryModel> getDetailedHistory({
    int limit = 10,
    int page = 1,
    String? status,
    String? month,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await authToken;
      
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };
      
      if (status != null) queryParams['status'] = status;
      if (month != null) queryParams['month'] = month;
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;
      
      final response = await dio.get(
        '$baseUrl/attendance/detailed-history',
        queryParameters: queryParams,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return AttendanceHistoryModel.fromJson(response.data);
      } else {
        throw ServerException(message: 'Failed to get detailed history');
      }
    } catch (e) {
      throw ServerException(message: 'Network error: $e');
    }
  }
}