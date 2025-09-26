import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetTodayAttendance implements UseCase<TodayAttendance, NoParams> {
  final AttendanceRepository repository;

  GetTodayAttendance(this.repository);

  @override
  Future<Either<Failure, TodayAttendance>> call(NoParams params) async {
    return await repository.getTodayAttendance();
  }
}