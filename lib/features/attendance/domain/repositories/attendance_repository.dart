import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/attendance.dart';
import '../entities/leave_approval.dart';
import '../entities/attendance_statistics.dart';
import '../entities/monthly_statistics.dart';
import '../entities/attendance_history.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, TodayAttendance>> getTodayAttendance();
  Future<Either<Failure, Attendance>> checkIn(
    String status, 
    String? documentation,
    {String? latitude, String? longitude, String? location}
  );
  Future<Either<Failure, Attendance>> checkInWithLeave({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    required dynamic document,
    String? latitude,
    String? longitude,
    String? location,
  });
  Future<Either<Failure, Attendance>> checkOut();
  Future<Either<Failure, Attendance>> checkOutWithOvertime(String reason, String? notes);
  Future<Either<Failure, List<Attendance>>> getAttendanceHistory(String month);
  Future<Either<Failure, LeaveApproval>> submitLeaveRequest({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    String? document,
  });
  Future<Either<Failure, List<Attendance>>> getRecentAttendance();
  Future<Either<Failure, AttendanceStatistics>> getAttendanceStatistics(String year);
  Future<Either<Failure, List<MonthlyStatistics>>> getMonthlyStatistics(String year);
  Future<Either<Failure, AttendanceHistory>> getDetailedHistory({
    int limit = 10,
    int page = 1,
    String? status,
    String? month,
    String? startDate,
    String? endDate,
  });
}