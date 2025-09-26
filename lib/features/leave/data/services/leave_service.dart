import 'package:dio/dio.dart';
import '../../domain/entities/leave_approval.dart';

class LeaveService {
  final Dio _dio;
  
  LeaveService(this._dio);

  // Get leave data from existing attendance API
  Future<List<LeaveApproval>> getLeaveData() async {
    try {
      final response = await _dio.get('/attendance/leave-data');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((item) => LeaveApproval.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get leave data');
      }
    } catch (e) {
      throw Exception('Failed to get leave data: $e');
    }
  }

  // Submit leave request through check-in API with status = 'leave'
  Future<Map<String, dynamic>> submitLeaveRequest({
    required String documentation,
    required String startDate,
    required String endDate,
    required String type,
  }) async {
    try {
      final response = await _dio.post('/attendance/check-in', data: {
        'status': 'leave',
        'documentation': documentation,
        // Additional data for leave tracking
        'start_date': startDate,
        'end_date': endDate,
        'leave_type': type,
      });
      
      if (response.statusCode == 201) {
        return response.data;
      } else {
        throw Exception('Failed to submit leave request');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic> && errorData.containsKey('message')) {
          throw Exception(errorData['message']);
        }
      }
      throw Exception('Failed to submit leave request: $e');
    }
  }

  // Get leave statistics based on attendance summary
  Future<Map<String, dynamic>> getLeaveStatistics({String? month}) async {
    try {
      final response = await _dio.get('/attendance/summary', queryParameters: {
        if (month != null) 'month': month,
      });
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get leave statistics');
      }
    } catch (e) {
      throw Exception('Failed to get leave statistics: $e');
    }
  }

  // Check if user can submit leave (no attendance today)
  Future<bool> canSubmitLeave() async {
    try {
      final response = await _dio.get('/attendance/today');
      
      if (response.statusCode == 200) {
        final attendance = response.data['attendance'];
        return attendance == null; // Can submit leave if no attendance today
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}