import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_today_attendance.dart';
import '../../domain/usecases/check_in.dart';
import '../../domain/usecases/check_in_with_leave.dart';
import '../../domain/usecases/check_out.dart';
import '../../domain/usecases/check_out_with_overtime.dart';
import '../../domain/usecases/get_recent_attendance.dart';
import 'attendance_event.dart';
import 'attendance_state.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GetTodayAttendance getTodayAttendance;
  final CheckIn checkIn;
  final CheckInWithLeave checkInWithLeave;
  final CheckOut checkOut;
  final CheckOutWithOvertime checkOutWithOvertime;
  final GetRecentAttendance getRecentAttendance;
  final SharedPreferences sharedPreferences;

  AttendanceBloc({
    required this.getTodayAttendance,
    required this.checkIn,
    required this.checkInWithLeave,
    required this.checkOut,
    required this.checkOutWithOvertime,
    required this.getRecentAttendance,
    required this.sharedPreferences,
  }) : super(AttendanceInitial()) {
    on<GetTodayAttendanceEvent>(_onGetTodayAttendance);
    on<CheckInEvent>(_onCheckIn);
    on<CheckInWithLeaveEvent>(_onCheckInWithLeave);
    on<CheckOutEvent>(_onCheckOut);
    on<CheckOutWithOvertimeEvent>(_onCheckOutWithOvertime);
    on<GetRecentAttendanceEvent>(_onGetRecentAttendance);
  }

  void _onGetTodayAttendance(
    GetTodayAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    emit(AttendanceLoading());
    
    // Get user info from shared preferences
    final userJson = sharedPreferences.getString('USER_DATA');
    String? photoUrl;
    String username = 'User';
    
    if (userJson != null) {
      try {
        final userData = Map<String, dynamic>.from(
          (sharedPreferences.get('USER_DATA') as Map?) ?? {}
        );
        photoUrl = userData['photo_url'] as String?;
        username = userData['name'] as String? ?? 'User';
      } catch (e) {
        print('Error parsing user data: $e');
      }
    }
    
    final result = await getTodayAttendance(NoParams());
    
    result.fold(
      (failure) => emit(AttendanceError(message: failure.message)),
      (todayAttendance) {
        emit(AttendanceLoaded(
          todayAttendance: todayAttendance,
          photoUrl: photoUrl,
          username: username,
        ));
        // Also get recent attendance
        add(GetRecentAttendanceEvent());
      },
    );
  }

  void _onCheckIn(
    CheckInEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await checkIn(CheckInParams(
      status: event.status,
      documentation: event.documentation,
      latitude: event.latitude,
      longitude: event.longitude,
      location: event.location,
    ));
    
    result.fold(
      (failure) => emit(AttendanceError(message: failure.message)),
      (attendance) {
        // Add delay to allow database to update
        Future.delayed(const Duration(milliseconds: 500), () {
          add(GetTodayAttendanceEvent());
        });
      },
    );
  }

  void _onCheckInWithLeave(
    CheckInWithLeaveEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await checkInWithLeave(CheckInWithLeaveParams(
      leaveReason: event.leaveReason,
      startDate: event.startDate,
      endDate: event.endDate,
      totalDays: event.totalDays,
      type: event.type,
      document: event.document,
      latitude: event.latitude,
      longitude: event.longitude,
      location: event.location,
    ));
    
    result.fold(
      (failure) => emit(AttendanceError(message: failure.message)),
      (attendance) {
        // Add delay to allow database to update
        Future.delayed(const Duration(milliseconds: 500), () {
          add(GetTodayAttendanceEvent());
        });
      },
    );
  }

  void _onCheckOut(
    CheckOutEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await checkOut(NoParams());
    
    result.fold(
      (failure) => emit(AttendanceError(message: failure.message)),
      (attendance) {
        // Refresh today's attendance after successful check-out
        add(GetTodayAttendanceEvent());
      },
    );
  }

  void _onCheckOutWithOvertime(
    CheckOutWithOvertimeEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await checkOutWithOvertime(
      CheckOutWithOvertimeParams(
        reason: event.reason,
        notes: event.notes,
      ),
    );
    
    result.fold(
      (failure) => emit(AttendanceError(message: failure.message)),
      (attendance) {
        // Refresh today's attendance after successful check-out
        add(GetTodayAttendanceEvent());
      },
    );
  }

  void _onGetRecentAttendance(
    GetRecentAttendanceEvent event,
    Emitter<AttendanceState> emit,
  ) async {
    final result = await getRecentAttendance(NoParams());
    
    result.fold(
      (failure) {
        // Don't emit error for recent attendance, just keep current state
      },
      (recentAttendance) {
        final currentState = state;
        if (currentState is AttendanceLoaded) {
          emit(currentState.copyWith(recentAttendance: recentAttendance));
        }
      },
    );
  }
}