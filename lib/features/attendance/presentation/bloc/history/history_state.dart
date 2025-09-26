part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryLoadingMore extends HistoryState {
  final AttendanceStatistics? statistics;
  final List<MonthlyStatistics>? monthlyStats;
  final AttendanceHistory? detailedHistory;

  const HistoryLoadingMore({
    this.statistics,
    this.monthlyStats,
    this.detailedHistory,
  });

  @override
  List<Object?> get props => [statistics, monthlyStats, detailedHistory];
}

class HistoryLoaded extends HistoryState {
  final AttendanceStatistics? statistics;
  final List<MonthlyStatistics>? monthlyStats;
  final AttendanceHistory? detailedHistory;
  final String currentYear;
  final String? currentFilter;
  final String? currentMonth;
  final String? currentStartDate;
  final String? currentEndDate;

  const HistoryLoaded({
    this.statistics,
    this.monthlyStats,
    this.detailedHistory,
    required this.currentYear,
    this.currentFilter,
    this.currentMonth,
    this.currentStartDate,
    this.currentEndDate,
  });

  @override
  List<Object?> get props => [
        statistics,
        monthlyStats,
        detailedHistory,
        currentYear,
        currentFilter,
        currentMonth,
        currentStartDate,
        currentEndDate,
      ];

  HistoryLoaded copyWith({
    AttendanceStatistics? statistics,
    List<MonthlyStatistics>? monthlyStats,
    AttendanceHistory? detailedHistory,
    String? currentYear,
    String? currentFilter,
    String? currentMonth,
    String? currentStartDate,
    String? currentEndDate,
  }) {
    return HistoryLoaded(
      statistics: statistics ?? this.statistics,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      detailedHistory: detailedHistory ?? this.detailedHistory,
      currentYear: currentYear ?? this.currentYear,
      currentFilter: currentFilter ?? this.currentFilter,
      currentMonth: currentMonth ?? this.currentMonth,
      currentStartDate: currentStartDate ?? this.currentStartDate,
      currentEndDate: currentEndDate ?? this.currentEndDate,
    );
  }
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}