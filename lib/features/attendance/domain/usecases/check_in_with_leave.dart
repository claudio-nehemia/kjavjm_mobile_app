import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class CheckInWithLeave implements UseCase<Attendance, CheckInWithLeaveParams> {
  final AttendanceRepository repository;

  CheckInWithLeave(this.repository);

  @override
  Future<Either<Failure, Attendance>> call(CheckInWithLeaveParams params) async {
    return await repository.checkInWithLeave(
      leaveReason: params.leaveReason,
      startDate: params.startDate,
      endDate: params.endDate,
      totalDays: params.totalDays,
      type: params.type,
      document: params.document,
    );
  }
}

class CheckInWithLeaveParams {
  final String leaveReason;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String type;
  final dynamic document;

  CheckInWithLeaveParams({
    required this.leaveReason,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.type,
    required this.document,
  });
}