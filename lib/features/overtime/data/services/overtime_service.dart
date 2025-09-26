import 'package:dio/dio.dart';
import '../../domain/entities/overtime.dart';

class OvertimeService {
  final Dio _dio;
  
  OvertimeService(this._dio);

  // Get overtime data from attendance API
  Future<List<Overtime>> getOvertimeData({String? month, String? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '/attendance/overtime-data',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((item) => Overtime.fromJson(item)).toList();
      } else {
        throw Exception('Failed to get overtime data');
      }
    } catch (e) {
      throw Exception('Failed to get overtime data: $e');
    }
  }

  // Get overtime statistics
  Future<Map<String, dynamic>> getOvertimeStatistics({String? year}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '/attendance/overtime-statistics',
        queryParameters: queryParams,
      );
      
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to get overtime statistics');
      }
    } catch (e) {
      throw Exception('Failed to get overtime statistics: $e');
    }
  }

  // Check if user has overtime today (from today's attendance)
  Future<Map<String, dynamic>> getTodayOvertimeStatus() async {
    try {
      final response = await _dio.get('/attendance/today');
      
      if (response.statusCode == 200) {
        final data = response.data;
        final attendance = data['attendance'];
        final rules = data['rules'];
        
        if (attendance != null && rules != null) {
          final checkOut = attendance['check_out'];
          final startOvertime = rules['start_overtime'];
          
          bool hasOvertime = false;
          if (checkOut != null && startOvertime != null) {
            // Parse times and compare
            final checkOutTime = DateTime.parse('2023-01-01 $checkOut');
            final overtimeStart = DateTime.parse('2023-01-01 $startOvertime');
            hasOvertime = checkOutTime.isAfter(overtimeStart);
          }
          
          return {
            'has_overtime': hasOvertime,
            'check_out': checkOut,
            'start_overtime': startOvertime,
            'attendance': attendance,
            'rules': rules,
          };
        }
        
        return {
          'has_overtime': false,
          'message': 'No attendance data for today',
        };
      } else {
        throw Exception('Failed to get today attendance status');
      }
    } catch (e) {
      throw Exception('Failed to get today overtime status: $e');
    }
  }

  // Note: Overtime creation is automatic through check-out API
  // No manual overtime submission needed as it's handled by attendance system
}