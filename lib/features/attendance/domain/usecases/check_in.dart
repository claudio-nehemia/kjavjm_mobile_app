import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class CheckIn implements UseCase<Attendance, CheckInParams> {
  final AttendanceRepository repository;

  CheckIn(this.repository);

  @override
  Future<Either<Failure, Attendance>> call(CheckInParams params) async {
    return await repository.checkIn(params.status, params.documentation);
  }
}

class CheckInParams extends Equatable {
  final String status;
  final String? documentation;

  const CheckInParams({
    required this.status,
    this.documentation,
  });

  @override
  List<Object?> get props => [status, documentation];
}