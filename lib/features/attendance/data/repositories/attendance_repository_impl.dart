import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/leave_approval.dart';
import '../../domain/entities/attendance_statistics.dart';
import '../../domain/entities/monthly_statistics.dart';
import '../../domain/entities/attendance_history.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_data_source.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, TodayAttendance>> getTodayAttendance() async {
    try {
      final result = await remoteDataSource.getTodayAttendance();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Attendance>> checkIn(String status, String? documentation) async {
    try {
      final result = await remoteDataSource.checkIn(status, documentation);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Attendance>> checkInWithLeave({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    required dynamic document,
  }) async {
    try {
      final result = await remoteDataSource.checkInWithLeave(
        leaveReason: leaveReason,
        startDate: startDate,
        endDate: endDate,
        totalDays: totalDays,
        type: type,
        document: document,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Attendance>> checkOut() async {
    try {
      final result = await remoteDataSource.checkOut();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, Attendance>> checkOutWithOvertime(String reason, String? notes) async {
    try {
      final result = await remoteDataSource.checkOutWithOvertime(reason, notes);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attendance>>> getAttendanceHistory(String month) async {
    try {
      final result = await remoteDataSource.getAttendanceHistory(month);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, LeaveApproval>> submitLeaveRequest({
    required String leaveReason,
    required String startDate,
    required String endDate,
    required int totalDays,
    required String type,
    String? document,
  }) async {
    try {
      final result = await remoteDataSource.submitLeaveRequest(
        leaveReason: leaveReason,
        startDate: startDate,
        endDate: endDate,
        totalDays: totalDays,
        type: type,
        document: document,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<Attendance>>> getRecentAttendance() async {
    try {
      final result = await remoteDataSource.getRecentAttendance();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AttendanceStatistics>> getAttendanceStatistics(String year) async {
    try {
      final result = await remoteDataSource.getAttendanceStatistics(year);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, List<MonthlyStatistics>>> getMonthlyStatistics(String year) async {
    try {
      final result = await remoteDataSource.getMonthlyStatistics(year);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, AttendanceHistory>> getDetailedHistory({
    int limit = 10,
    int page = 1,
    String? status,
    String? month,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final result = await remoteDataSource.getDetailedHistory(
        limit: limit,
        page: page,
        status: status,
        month: month,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    }
  }
}