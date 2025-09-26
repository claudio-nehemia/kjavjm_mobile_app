import 'package:equatable/equatable.dart';

class LeaveApproval extends Equatable {
  final int id;
  final int userId;
  final int? attendanceId;
  final String leaveReason;
  final String status;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String type;
  final String? document;

  const LeaveApproval({
    required this.id,
    required this.userId,
    this.attendanceId,
    required this.leaveReason,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.type,
    this.document,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        attendanceId,
        leaveReason,
        status,
        startDate,
        endDate,
        totalDays,
        type,
        document,
      ];
}