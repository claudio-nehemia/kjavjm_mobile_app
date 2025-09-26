import '../../domain/entities/attendance_statistics.dart';

class AttendanceStatisticsModel extends AttendanceStatistics {
  const AttendanceStatisticsModel({
    required super.totalDays,
    required super.presentDays,
    required super.lateDays,
    required super.leaveDays,
    required super.absentDays,
    required super.overtimeDays,
    required super.presentPercentage,
    required super.latePercentage,
    required super.leavePercentage,
    required super.absentPercentage,
  });

  factory AttendanceStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AttendanceStatisticsModel(
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      leaveDays: json['leave_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
      overtimeDays: json['overtime_days'] ?? 0,
      presentPercentage: (json['present_percentage'] ?? 0.0).toDouble(),
      latePercentage: (json['late_percentage'] ?? 0.0).toDouble(),
      leavePercentage: (json['leave_percentage'] ?? 0.0).toDouble(),
      absentPercentage: (json['absent_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_days': totalDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'leave_days': leaveDays,
      'absent_days': absentDays,
      'overtime_days': overtimeDays,
      'present_percentage': presentPercentage,
      'late_percentage': latePercentage,
      'leave_percentage': leavePercentage,
      'absent_percentage': absentPercentage,
    };
  }

  AttendanceStatisticsModel copyWith({
    int? totalDays,
    int? presentDays,
    int? lateDays,
    int? leaveDays,
    int? absentDays,
    int? overtimeDays,
    double? presentPercentage,
    double? latePercentage,
    double? leavePercentage,
    double? absentPercentage,
  }) {
    return AttendanceStatisticsModel(
      totalDays: totalDays ?? this.totalDays,
      presentDays: presentDays ?? this.presentDays,
      lateDays: lateDays ?? this.lateDays,
      leaveDays: leaveDays ?? this.leaveDays,
      absentDays: absentDays ?? this.absentDays,
      overtimeDays: overtimeDays ?? this.overtimeDays,
      presentPercentage: presentPercentage ?? this.presentPercentage,
      latePercentage: latePercentage ?? this.latePercentage,
      leavePercentage: leavePercentage ?? this.leavePercentage,
      absentPercentage: absentPercentage ?? this.absentPercentage,
    );
  }
}