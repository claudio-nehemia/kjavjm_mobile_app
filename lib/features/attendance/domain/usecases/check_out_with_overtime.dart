import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance.dart';
import '../repositories/attendance_repository.dart';

class CheckOutWithOvertime implements UseCase<Attendance, CheckOutWithOvertimeParams> {
  final AttendanceRepository repository;

  CheckOutWithOvertime(this.repository);

  @override
  Future<Either<Failure, Attendance>> call(CheckOutWithOvertimeParams params) async {
    return await repository.checkOutWithOvertime(params.reason, params.notes);
  }
}

class CheckOutWithOvertimeParams extends Equatable {
  final String reason;
  final String? notes;

  const CheckOutWithOvertimeParams({
    required this.reason,
    this.notes,
  });

  @override
  List<Object?> get props => [reason, notes];
}