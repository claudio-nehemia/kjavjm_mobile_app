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
  final String? latitude;
  final String? longitude;
  final String? location;

  const CheckInEvent({
    required this.status,
    this.documentation,
    this.latitude,
    this.longitude,
    this.location,
  });

  @override
  List<Object?> get props => [status, documentation, latitude, longitude, location];
}

class CheckInWithLeaveEvent extends AttendanceEvent {
  final String leaveReason;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String type;
  final dynamic document;
  final String? latitude;
  final String? longitude;
  final String? location;

  const CheckInWithLeaveEvent({
    required this.leaveReason,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.type,
    required this.document,
    this.latitude,
    this.longitude,
    this.location,
  });

  @override
  List<Object?> get props => [leaveReason, startDate, endDate, totalDays, type, document, latitude, longitude, location];
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