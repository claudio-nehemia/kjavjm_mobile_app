import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'core/config/web_config.dart';
import 'core/config/mobile_http_config.dart'
    if (dart.library.html) 'core/config/mobile_http_config_web.dart';

// Domain
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/check_auth_status.dart';
import 'features/dashboard/domain/repositories/dashboard_repository.dart';
import 'features/dashboard/domain/usecases/get_dashboard_data.dart';
import 'features/attendance/domain/repositories/attendance_repository.dart';
import 'features/attendance/domain/usecases/get_today_attendance.dart';
import 'features/attendance/domain/usecases/check_in.dart';
import 'features/attendance/domain/usecases/check_in_with_leave.dart';
import 'features/attendance/domain/usecases/check_out.dart';
import 'features/attendance/domain/usecases/check_out_with_overtime.dart';
import 'features/attendance/domain/usecases/get_recent_attendance.dart';
import 'features/attendance/domain/usecases/get_attendance_statistics.dart';
import 'features/attendance/domain/usecases/get_monthly_statistics.dart';
import 'features/attendance/domain/usecases/get_detailed_attendance_history.dart';


// Data
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'features/dashboard/data/datasources/dashboard_remote_data_source.dart';
import 'features/attendance/data/repositories/attendance_repository_impl.dart';
import 'features/attendance/data/datasources/attendance_remote_data_source.dart';


// Presentation
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/attendance/presentation/bloc/attendance_bloc.dart';
import 'features/attendance/presentation/bloc/history/history_bloc.dart';

import 'features/profile/data/services/profile_service.dart';

// Leave and Overtime Services
import 'features/leave/data/services/leave_service.dart';
import 'features/overtime/data/services/overtime_service.dart';

// Core Services
import 'core/services/auto_refresh_service.dart';
import 'core/services/persistent_login_service.dart';
import 'core/services/location_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Dio
  final dio = Dio();
  dio.options.baseUrl = WebConfig.apiBaseUrl; // Use WebConfig with fallback
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);
  dio.options.sendTimeout = const Duration(seconds: 30);
  
  // Configure mobile HTTP client with SSL handling (no-op on web)
  configureMobileHttpClient(dio);
  
  // Add logging interceptor
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (object) => print('🌐 API Log: $object'),
  ));
  
  // Add auth token interceptor
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = sharedPreferences.getString('AUTH_TOKEN');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      options.headers['Accept'] = 'application/json';
      options.headers['Content-Type'] = 'application/json';
      
      print('🚀 API Request: ${options.method} ${options.path}');
      if (options.data != null) {
        print('📤 Request Data: ${options.data}');
      }
      
      handler.next(options);
    },
    onResponse: (response, handler) {
      print('✅ API Response: ${response.statusCode} ${response.requestOptions.path}');
      print('📦 Response Data: ${response.data}');
      handler.next(response);
    },
    onError: (error, handler) {
      print('❌ API Error: ${error.message}');
      print('📋 Error Response: ${error.response?.data}');
      handler.next(error);
    },
  ));
  
  sl.registerLazySingleton(() => dio);

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl(),
      baseUrl: WebConfig.apiBaseUrl, // Use WebConfig with fallback
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(
      dio: sl(),
      sharedPreferences: sl(),
    ),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatus(sl()));
  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayAttendance(sl()));
  sl.registerLazySingleton(() => CheckIn(sl()));
  sl.registerLazySingleton(() => CheckInWithLeave(sl()));
  sl.registerLazySingleton(() => CheckOut(sl()));
  sl.registerLazySingleton(() => CheckOutWithOvertime(sl()));
  sl.registerLazySingleton(() => GetRecentAttendance(sl()));
  sl.registerLazySingleton(() => GetAttendanceStatistics(sl()));
  sl.registerLazySingleton(() => GetMonthlyStatistics(sl()));
  sl.registerLazySingleton(() => GetDetailedAttendanceHistory(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatus: sl(),
      persistentLoginService: sl(),
    ),
  );

  sl.registerFactory(
    () => DashboardBloc(getDashboardDataUseCase: sl()),
  );

  sl.registerFactory(
    () => AttendanceBloc(
      getTodayAttendance: sl(),
      checkIn: sl(),
      checkInWithLeave: sl(),
      checkOut: sl(),
      checkOutWithOvertime: sl(),
      getRecentAttendance: sl(),
      sharedPreferences: sl(),
    ),
  );

  sl.registerFactory(
    () => HistoryBloc(
      getAttendanceStatistics: sl(),
      getMonthlyStatistics: sl(),
      getDetailedAttendanceHistory: sl(),
    ),
  );

  // Services
  sl.registerLazySingleton(() => ProfileService(sl()));
  sl.registerLazySingleton(() => LeaveService(sl()));
  sl.registerLazySingleton(() => OvertimeService(sl()));
  sl.registerLazySingleton(() => AutoRefreshService());
  sl.registerLazySingleton(() => PersistentLoginService(sl()));
  sl.registerLazySingleton(() => LocationService());
}