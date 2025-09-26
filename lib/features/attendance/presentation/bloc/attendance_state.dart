import 'package:equatable/equatable.dart';
import '../../domain/entities/attendance.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object?> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final TodayAttendance todayAttendance;
  final List<Attendance>? recentAttendance;

  const AttendanceLoaded({
    required this.todayAttendance,
    this.recentAttendance,
  });

  @override
  List<Object?> get props => [todayAttendance, recentAttendance];

  AttendanceLoaded copyWith({
    TodayAttendance? todayAttendance,
    List<Attendance>? recentAttendance,
  }) {
    return AttendanceLoaded(
      todayAttendance: todayAttendance ?? this.todayAttendance,
      recentAttendance: recentAttendance ?? this.recentAttendance,
    );
  }
}

class AttendanceError extends AttendanceState {
  final String message;

  const AttendanceError({required this.message});

  @override
  List<Object> get props => [message];
}

class AttendanceActionSuccess extends AttendanceState {
  final String message;
  final TodayAttendance updatedAttendance;

  const AttendanceActionSuccess({
    required this.message,
    required this.updatedAttendance,
  });

  @override
  List<Object> get props => [message, updatedAttendance];
}