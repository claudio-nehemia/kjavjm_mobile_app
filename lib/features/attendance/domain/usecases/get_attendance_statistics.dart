import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_statistics.dart';
import '../repositories/attendance_repository.dart';

class GetAttendanceStatistics implements UseCase<AttendanceStatistics, GetAttendanceStatisticsParams> {
  final AttendanceRepository repository;

  GetAttendanceStatistics(this.repository);

  @override
  Future<Either<Failure, AttendanceStatistics>> call(GetAttendanceStatisticsParams params) async {
    return await repository.getAttendanceStatistics(params.year);
  }
}

class GetAttendanceStatisticsParams {
  final String year;

  GetAttendanceStatisticsParams({required this.year});
}