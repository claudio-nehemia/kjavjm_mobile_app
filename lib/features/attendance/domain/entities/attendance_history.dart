import 'attendance.dart';

class AttendanceHistory {
  final List<Attendance> data;
  final AttendancePagination pagination;
  final AttendanceFilters? filters;

  const AttendanceHistory({
    required this.data,
    required this.pagination,
    this.filters,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceHistory &&
          runtimeType == other.runtimeType &&
          data == other.data &&
          pagination == other.pagination &&
          filters == other.filters;

  @override
  int get hashCode => data.hashCode ^ pagination.hashCode ^ filters.hashCode;

  @override
  String toString() {
    return 'AttendanceHistory{data: $data, pagination: $pagination, filters: $filters}';
  }
}

class AttendancePagination {
  final int currentPage;
  final int perPage;
  final int total;
  final int lastPage;

  const AttendancePagination({
    required this.currentPage,
    required this.perPage,
    required this.total,
    required this.lastPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendancePagination &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          perPage == other.perPage &&
          total == other.total &&
          lastPage == other.lastPage;

  @override
  int get hashCode =>
      currentPage.hashCode ^ perPage.hashCode ^ total.hashCode ^ lastPage.hashCode;

  @override
  String toString() {
    return 'AttendancePagination{currentPage: $currentPage, perPage: $perPage, total: $total, lastPage: $lastPage}';
  }
}

class AttendanceFilters {
  final String? status;
  final String? month;
  final String? startDate;
  final String? endDate;

  const AttendanceFilters({
    this.status,
    this.month,
    this.startDate,
    this.endDate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceFilters &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          month == other.month &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode =>
      status.hashCode ^ month.hashCode ^ startDate.hashCode ^ endDate.hashCode;

  @override
  String toString() {
    return 'AttendanceFilters{status: $status, month: $month, startDate: $startDate, endDate: $endDate}';
  }
}