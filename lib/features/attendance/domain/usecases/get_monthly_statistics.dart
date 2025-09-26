import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/monthly_statistics.dart';
import '../repositories/attendance_repository.dart';

class GetMonthlyStatistics implements UseCase<List<MonthlyStatistics>, GetMonthlyStatisticsParams> {
  final AttendanceRepository repository;

  GetMonthlyStatistics(this.repository);

  @override
  Future<Either<Failure, List<MonthlyStatistics>>> call(GetMonthlyStatisticsParams params) async {
    return await repository.getMonthlyStatistics(params.year);
  }
}

class GetMonthlyStatisticsParams {
  final String year;

  GetMonthlyStatisticsParams({required this.year});
}