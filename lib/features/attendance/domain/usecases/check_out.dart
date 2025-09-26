import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class CheckOut implements UseCase<Attendance, NoParams> {
  final AttendanceRepository repository;

  CheckOut(this.repository);

  @override
  Future<Either<Failure, Attendance>> call(NoParams params) async {
    return await repository.checkOut();
  }
}