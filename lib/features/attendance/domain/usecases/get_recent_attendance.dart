import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class GetRecentAttendance implements UseCase<List<Attendance>, NoParams> {
  final AttendanceRepository repository;

  GetRecentAttendance(this.repository);

  @override
  Future<Either<Failure, List<Attendance>>> call(NoParams params) async {
    return await repository.getRecentAttendance();
  }
}