part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadAttendanceStatistics extends HistoryEvent {
  final String year;

  const LoadAttendanceStatistics({required this.year});

  @override
  List<Object?> get props => [year];
}

class LoadMonthlyStatistics extends HistoryEvent {
  final String year;

  const LoadMonthlyStatistics({required this.year});

  @override
  List<Object?> get props => [year];
}

class LoadDetailedHistory extends HistoryEvent {
  final int limit;
  final int page;
  final String? status;
  final String? month;
  final String? startDate;
  final String? endDate;

  const LoadDetailedHistory({
    this.limit = 10,
    this.page = 1,
    this.status,
    this.month,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [limit, page, status, month, startDate, endDate];
}

class FilterHistoryByStatus extends HistoryEvent {
  final String? status;

  const FilterHistoryByStatus({this.status});

  @override
  List<Object?> get props => [status];
}

class FilterHistoryByMonth extends HistoryEvent {
  final String? month;

  const FilterHistoryByMonth({this.month});

  @override
  List<Object?> get props => [month];
}

class FilterHistoryByDateRange extends HistoryEvent {
  final String? startDate;
  final String? endDate;

  const FilterHistoryByDateRange({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

class LoadMoreHistory extends HistoryEvent {
  const LoadMoreHistory();
}

class RefreshHistoryData extends HistoryEvent {
  const RefreshHistoryData();
}