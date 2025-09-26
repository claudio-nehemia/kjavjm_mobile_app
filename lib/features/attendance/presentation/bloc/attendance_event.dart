import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class GetTodayAttendanceEvent extends AttendanceEvent {}

class CheckInEvent extends AttendanceEvent {
  final String status;
  final String? documentation;

  const CheckInEvent({
    required this.status,
    this.documentation,
  });

  @override
  List<Object?> get props => [status, documentation];
}

class CheckInWithLeaveEvent extends AttendanceEvent {
  final String leaveReason;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String type;
  final dynamic document;

  const CheckInWithLeaveEvent({
    required this.leaveReason,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.type,
    required this.document,
  });

  @override
  List<Object?> get props => [leaveReason, startDate, endDate, totalDays, type, document];
}

class CheckOutEvent extends AttendanceEvent {}

class CheckOutWithOvertimeEvent extends AttendanceEvent {
  final String reason;
  final String? notes;

  const CheckOutWithOvertimeEvent({
    required this.reason,
    this.notes,
  });

  @override
  List<Object?> get props => [reason, notes];
}

class GetRecentAttendanceEvent extends AttendanceEvent {}