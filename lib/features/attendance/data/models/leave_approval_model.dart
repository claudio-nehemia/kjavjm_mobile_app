import '../../domain/entities/leave_approval.dart';

class LeaveApprovalModel extends LeaveApproval {
  const LeaveApprovalModel({
    required super.id,
    required super.userId,
    super.attendanceId,
    required super.leaveReason,
    required super.status,
    required super.startDate,
    required super.endDate,
    required super.totalDays,
    required super.type,
    super.document,
  });

  factory LeaveApprovalModel.fromJson(Map<String, dynamic> json) {
    return LeaveApprovalModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      attendanceId: json['attendance_id'],
      leaveReason: json['leave_reason'] ?? '',
      status: json['status'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalDays: json['total_days'] ?? 0,
      type: json['type'] ?? '',
      document: json['document'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'attendance_id': attendanceId,
      'leave_reason': leaveReason,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'type': type,
      'document': document,
    };
  }
}