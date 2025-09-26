import '../../domain/entities/attendance_history.dart';
import 'attendance_model.dart';

class AttendanceHistoryModel extends AttendanceHistory {
  const AttendanceHistoryModel({
    required super.data,
    required super.pagination,
    super.filters,
  });

  factory AttendanceHistoryModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    final List<AttendanceModel> attendances = dataList
        .map((item) => AttendanceModel.fromJson(item))
        .toList();

    return AttendanceHistoryModel(
      data: attendances,
      pagination: AttendancePaginationModel.fromJson(json['pagination'] ?? {}),
      filters: json['filters'] != null 
          ? AttendanceFiltersModel.fromJson(json['filters'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((attendance) => 
          (attendance as AttendanceModel).toJson()).toList(),
      'pagination': (pagination as AttendancePaginationModel).toJson(),
      'filters': filters != null 
          ? (filters as AttendanceFiltersModel).toJson()
          : null,
    };
  }
}

class AttendancePaginationModel extends AttendancePagination {
  const AttendancePaginationModel({
    required super.currentPage,
    required super.perPage,
    required super.total,
    required super.lastPage,
  });

  factory AttendancePaginationModel.fromJson(Map<String, dynamic> json) {
    return AttendancePaginationModel(
      currentPage: json['current_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
      lastPage: json['last_page'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'per_page': perPage,
      'total': total,
      'last_page': lastPage,
    };
  }
}

class AttendanceFiltersModel extends AttendanceFilters {
  const AttendanceFiltersModel({
    super.status,
    super.month,
    super.startDate,
    super.endDate,
  });

  factory AttendanceFiltersModel.fromJson(Map<String, dynamic> json) {
    return AttendanceFiltersModel(
      status: json['status'],
      month: json['month'],
      startDate: json['start_date'],
      endDate: json['end_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'month': month,
      'start_date': startDate,
      'end_date': endDate,
    };
  }
}