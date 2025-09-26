import 'package:dartz/dartz.dart';
import '../entities/dashboard_data.dart';
import '../../../../core/error/failures.dart';

abstract class DashboardRepository {
  Future<Either<Failure, DashboardData>> getDashboardData();
}