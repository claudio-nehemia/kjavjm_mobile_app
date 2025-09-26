import 'package:equatable/equatable.dart';
import 'attendance_log.dart';

class AttendanceSummary extends Equatable {
  final int total;
  final int hadir;
  final int terlambat;
  final int izin;
  final int absen;

  const AttendanceSummary({
    required this.total,
    required this.hadir,
    required this.terlambat,
    required this.izin,
    required this.absen,
  });

  @override
  List<Object> get props => [total, hadir, terlambat, izin, absen];
}

class DashboardData extends Equatable {
  final String username;
  final String department;
  final String? profilePicture;
  final AttendanceSummary monthlySummary;
  final AttendanceSummary weeklySummary;
  final List<AttendanceLog> attendanceLog;

  const DashboardData({
    required this.username,
    required this.department,
    this.profilePicture,
    required this.monthlySummary,
    required this.weeklySummary,
    required this.attendanceLog,
  });

  @override
  List<Object?> get props => [username, department, profilePicture, monthlySummary, weeklySummary, attendanceLog];
}