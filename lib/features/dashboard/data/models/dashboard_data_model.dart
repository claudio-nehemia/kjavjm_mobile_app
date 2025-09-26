import '../../domain/entities/dashboard_data.dart';
import 'attendance_log_model.dart';

class AttendanceSummaryModel extends AttendanceSummary {
  const AttendanceSummaryModel({
    required super.total,
    required super.hadir,
    required super.terlambat,
    required super.izin,
    required super.absen,
  });

  factory AttendanceSummaryModel.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryModel(
      total: json['total'] ?? 0,
      hadir: json['hadir'] ?? 0,
      terlambat: json['terlambat'] ?? 0,
      izin: json['izin'] ?? 0,
      absen: json['absen'] ?? 0,
    );
  }
}

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.username,
    required super.department,
    super.profilePicture,
    required super.monthlySummary,
    required super.weeklySummary,
    required super.attendanceLog,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    final attendanceSummary = json['attendance_summary'] as Map<String, dynamic>?;
    
    return DashboardDataModel(
      username: json['username'] ?? '',
      department: json['department'] ?? '',
      profilePicture: json['profile_picture'],
      monthlySummary: AttendanceSummaryModel.fromJson(
        attendanceSummary?['monthly'] ?? {}
      ),
      weeklySummary: AttendanceSummaryModel.fromJson(
        attendanceSummary?['weekly'] ?? {}
      ),
      attendanceLog: (json['attendance_log'] as List<dynamic>?)
          ?.map((log) => AttendanceLogModel.fromJson(log))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'department': department,
      'profile_picture': profilePicture,
      'attendance_summary': {
        'monthly': {
          'total': monthlySummary.total,
          'hadir': monthlySummary.hadir,
          'terlambat': monthlySummary.terlambat,
          'izin': monthlySummary.izin,
          'absen': monthlySummary.absen,
        },
        'weekly': {
          'total': weeklySummary.total,
          'hadir': weeklySummary.hadir,
          'terlambat': weeklySummary.terlambat,
          'izin': weeklySummary.izin,
          'absen': weeklySummary.absen,
        }
      },
      'attendance_log': attendanceLog
          .map((log) => (log as AttendanceLogModel).toJson())
          .toList(),
    };
  }
}