import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/attendance_statistics.dart';
import '../../../domain/entities/monthly_statistics.dart';
import '../../../domain/entities/attendance_history.dart';
import '../../../domain/usecases/get_attendance_statistics.dart';
import '../../../domain/usecases/get_monthly_statistics.dart';
import '../../../domain/usecases/get_detailed_attendance_history.dart';

part 'history_event.dart';
part 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetAttendanceStatistics getAttendanceStatistics;
  final GetMonthlyStatistics getMonthlyStatistics;
  final GetDetailedAttendanceHistory getDetailedAttendanceHistory;

  HistoryBloc({
    required this.getAttendanceStatistics,
    required this.getMonthlyStatistics,
    required this.getDetailedAttendanceHistory,
  }) : super(const HistoryInitial()) {
    on<LoadAttendanceStatistics>(_onLoadAttendanceStatistics);
    on<LoadMonthlyStatistics>(_onLoadMonthlyStatistics);
    on<LoadDetailedHistory>(_onLoadDetailedHistory);
    on<FilterHistoryByStatus>(_onFilterHistoryByStatus);
    on<FilterHistoryByMonth>(_onFilterHistoryByMonth);
    on<FilterHistoryByDateRange>(_onFilterHistoryByDateRange);
    on<LoadMoreHistory>(_onLoadMoreHistory);
    on<RefreshHistoryData>(_onRefreshHistoryData);
  }

  Future<void> _onLoadAttendanceStatistics(
    LoadAttendanceStatistics event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoaded) {
      emit(const HistoryLoading());
    }

    final result = await getAttendanceStatistics(
      GetAttendanceStatisticsParams(year: event.year),
    );

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (statistics) {
        if (state is HistoryLoaded) {
          emit((state as HistoryLoaded).copyWith(
            statistics: statistics,
            currentYear: event.year,
          ));
        } else {
          emit(HistoryLoaded(
            statistics: statistics,
            currentYear: event.year,
          ));
        }
      },
    );
  }

  Future<void> _onLoadMonthlyStatistics(
    LoadMonthlyStatistics event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoaded) {
      emit(const HistoryLoading());
    }

    final result = await getMonthlyStatistics(
      GetMonthlyStatisticsParams(year: event.year),
    );

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (monthlyStats) {
        if (state is HistoryLoaded) {
          emit((state as HistoryLoaded).copyWith(
            monthlyStats: monthlyStats,
            currentYear: event.year,
          ));
        } else {
          emit(HistoryLoaded(
            monthlyStats: monthlyStats,
            currentYear: event.year,
          ));
        }
      },
    );
  }

  Future<void> _onLoadDetailedHistory(
    LoadDetailedHistory event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is! HistoryLoaded) {
      emit(const HistoryLoading());
    }

    final result = await getDetailedAttendanceHistory(
      GetDetailedAttendanceHistoryParams(
        limit: event.limit,
        page: event.page,
        status: event.status,
        month: event.month,
        startDate: event.startDate,
        endDate: event.endDate,
      ),
    );

    result.fold(
      (failure) => emit(HistoryError(message: failure.message)),
      (detailedHistory) {
        if (state is HistoryLoaded) {
          emit((state as HistoryLoaded).copyWith(
            detailedHistory: detailedHistory,
            currentFilter: event.status,
            currentMonth: event.month,
            currentStartDate: event.startDate,
            currentEndDate: event.endDate,
          ));
        } else {
          emit(HistoryLoaded(
            detailedHistory: detailedHistory,
            currentYear: DateTime.now().year.toString(),
            currentFilter: event.status,
            currentMonth: event.month,
            currentStartDate: event.startDate,
            currentEndDate: event.endDate,
          ));
        }
      },
    );
  }

  Future<void> _onFilterHistoryByStatus(
    FilterHistoryByStatus event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoaded) {
      final currentState = state as HistoryLoaded;
      
      add(LoadDetailedHistory(
        limit: currentState.detailedHistory?.pagination.perPage ?? 10,
        page: 1,
        status: event.status,
        month: currentState.currentMonth,
        startDate: currentState.currentStartDate,
        endDate: currentState.currentEndDate,
      ));
    }
  }

  Future<void> _onFilterHistoryByMonth(
    FilterHistoryByMonth event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoaded) {
      final currentState = state as HistoryLoaded;
      
      add(LoadDetailedHistory(
        limit: currentState.detailedHistory?.pagination.perPage ?? 10,
        page: 1,
        status: currentState.currentFilter,
        month: event.month,
        startDate: currentState.currentStartDate,
        endDate: currentState.currentEndDate,
      ));
    }
  }

  Future<void> _onFilterHistoryByDateRange(
    FilterHistoryByDateRange event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoaded) {
      final currentState = state as HistoryLoaded;
      
      add(LoadDetailedHistory(
        limit: currentState.detailedHistory?.pagination.perPage ?? 10,
        page: 1,
        status: currentState.currentFilter,
        month: currentState.currentMonth,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    }
  }

  Future<void> _onLoadMoreHistory(
    LoadMoreHistory event,
    Emitter<HistoryState> emit,
  ) async {
    if (state is HistoryLoaded) {
      final currentState = state as HistoryLoaded;
      
      if (currentState.detailedHistory != null) {
        final pagination = currentState.detailedHistory!.pagination;
        
        if (pagination.currentPage < pagination.lastPage) {
          emit(HistoryLoadingMore(
            statistics: currentState.statistics,
            monthlyStats: currentState.monthlyStats,
            detailedHistory: currentState.detailedHistory,
          ));
          
          final result = await getDetailedAttendanceHistory(
            GetDetailedAttendanceHistoryParams(
              limit: pagination.perPage,
              page: pagination.currentPage + 1,
              status: currentState.currentFilter,
              month: currentState.currentMonth,
              startDate: currentState.currentStartDate,
              endDate: currentState.currentEndDate,
            ),
          );

          result.fold(
            (failure) => emit(HistoryError(message: failure.message)),
            (moreHistory) {
              // Merge the data
              final allData = [
                ...currentState.detailedHistory!.data,
                ...moreHistory.data,
              ];
              
              final mergedHistory = AttendanceHistory(
                data: allData,
                pagination: moreHistory.pagination,
                filters: moreHistory.filters,
              );
              
              emit(currentState.copyWith(detailedHistory: mergedHistory));
            },
          );
        }
      }
    }
  }

  Future<void> _onRefreshHistoryData(
    RefreshHistoryData event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());
    
    try {
      if (state is HistoryLoaded) {
        final currentState = state as HistoryLoaded;
        
        // Load all data sequentially to avoid race conditions
        final currentYear = currentState.currentYear;
        
        // 1. Load statistics
        final statsResult = await getAttendanceStatistics(
          GetAttendanceStatisticsParams(year: currentYear),
        );
        
        AttendanceStatistics? statistics;
        statsResult.fold(
          (failure) {
            // Log error but continue with other requests
            print('Error loading statistics: ${failure.message}');
          },
          (data) => statistics = data,
        );
        
        // 2. Load monthly statistics
        final monthlyResult = await getMonthlyStatistics(
          GetMonthlyStatisticsParams(year: currentYear),
        );
        
        List<MonthlyStatistics>? monthlyStats;
        monthlyResult.fold(
          (failure) {
            print('Error loading monthly stats: ${failure.message}');
          },
          (data) => monthlyStats = data,
        );
        
        // 3. Load detailed history
        final historyResult = await getDetailedAttendanceHistory(
          GetDetailedAttendanceHistoryParams(
            limit: currentState.detailedHistory?.pagination.perPage ?? 10,
            page: 1,
            status: currentState.currentFilter,
            month: currentState.currentMonth,
            startDate: currentState.currentStartDate,
            endDate: currentState.currentEndDate,
          ),
        );
        
        historyResult.fold(
          (failure) {
            emit(HistoryError(message: failure.message));
          },
          (detailedHistory) {
            emit(HistoryLoaded(
              statistics: statistics ?? currentState.statistics,
              monthlyStats: monthlyStats ?? currentState.monthlyStats,
              detailedHistory: detailedHistory,
              currentYear: currentYear,
              currentFilter: currentState.currentFilter,
              currentMonth: currentState.currentMonth,
              currentStartDate: currentState.currentStartDate,
              currentEndDate: currentState.currentEndDate,
            ));
          },
        );
      } else {
        // Initial load
        final currentYear = DateTime.now().year.toString();
        
        // Load all data sequentially
        final statsResult = await getAttendanceStatistics(
          GetAttendanceStatisticsParams(year: currentYear),
        );
        
        AttendanceStatistics? statistics;
        statsResult.fold(
          (failure) => print('Error loading statistics: ${failure.message}'),
          (data) => statistics = data,
        );
        
        final monthlyResult = await getMonthlyStatistics(
          GetMonthlyStatisticsParams(year: currentYear),
        );
        
        List<MonthlyStatistics>? monthlyStats;
        monthlyResult.fold(
          (failure) => print('Error loading monthly stats: ${failure.message}'),
          (data) => monthlyStats = data,
        );
        
        final historyResult = await getDetailedAttendanceHistory(
          GetDetailedAttendanceHistoryParams(),
        );
        
        historyResult.fold(
          (failure) => emit(HistoryError(message: failure.message)),
          (detailedHistory) {
            emit(HistoryLoaded(
              statistics: statistics,
              monthlyStats: monthlyStats,
              detailedHistory: detailedHistory,
              currentYear: currentYear,
            ));
          },
        );
      }
    } catch (e) {
      emit(HistoryError(message: 'Terjadi kesalahan: ${e.toString()}'));
    }
  }
}