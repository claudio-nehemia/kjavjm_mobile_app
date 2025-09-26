import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_history.dart';
import '../repositories/attendance_repository.dart';

class GetDetailedAttendanceHistory implements UseCase<AttendanceHistory, GetDetailedAttendanceHistoryParams> {
  final AttendanceRepository repository;

  GetDetailedAttendanceHistory(this.repository);

  @override
  Future<Either<Failure, AttendanceHistory>> call(GetDetailedAttendanceHistoryParams params) async {
    return await repository.getDetailedHistory(
      limit: params.limit,
      page: params.page,
      status: params.status,
      month: params.month,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetDetailedAttendanceHistoryParams {
  final int limit;
  final int page;
  final String? status;
  final String? month;
  final String? startDate;
  final String? endDate;

  GetDetailedAttendanceHistoryParams({
    this.limit = 10,
    this.page = 1,
    this.status,
    this.month,
    this.startDate,
    this.endDate,
  });
}