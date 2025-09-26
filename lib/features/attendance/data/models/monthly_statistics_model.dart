import '../../domain/entities/monthly_statistics.dart';

class MonthlyStatisticsModel extends MonthlyStatistics {
  const MonthlyStatisticsModel({
    required super.month,
    required super.monthName,
    required super.totalDays,
    required super.presentDays,
    required super.lateDays,
    required super.leaveDays,
    required super.absentDays,
  });

  factory MonthlyStatisticsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatisticsModel(
      month: json['month'] ?? 0,
      monthName: json['month_name'] ?? '',
      totalDays: json['total_days'] ?? 0,
      presentDays: json['present_days'] ?? 0,
      lateDays: json['late_days'] ?? 0,
      leaveDays: json['leave_days'] ?? 0,
      absentDays: json['absent_days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'month_name': monthName,
      'total_days': totalDays,
      'present_days': presentDays,
      'late_days': lateDays,
      'leave_days': leaveDays,
      'absent_days': absentDays,
    };
  }

  MonthlyStatisticsModel copyWith({
    int? month,
    String? monthName,
    int? totalDays,
    int? presentDays,
    int? lateDays,
    int? leaveDays,
    int? absentDays,
  }) {
    return MonthlyStatisticsModel(
      month: month ?? this.month,
      monthName: monthName ?? this.monthName,
      totalDays: totalDays ?? this.totalDays,
      presentDays: presentDays ?? this.presentDays,
      lateDays: lateDays ?? this.lateDays,
      leaveDays: leaveDays ?? this.leaveDays,
      absentDays: absentDays ?? this.absentDays,
    );
  }
}