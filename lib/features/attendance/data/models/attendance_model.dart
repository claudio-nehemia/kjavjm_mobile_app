import '../../domain/entities/attendance.dart';

class AttendanceModel extends Attendance {
  const AttendanceModel({
    required super.id,
    required super.userId,
    required super.tanggal,
    required super.status,
    super.photoUrl,
    super.checkIn,
    super.checkOut,
    super.documentation,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? '',
      checkIn: json['check_in'],
      photoUrl: json['photo_url'],
      checkOut: json['check_out'],
      documentation: json['documentation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'tanggal': tanggal,
      'status': status,
      'check_in': checkIn,
      'check_out': checkOut,
      'documentation': documentation,
    };
  }
}

class AturanJamModel extends AturanJam {
  const AturanJamModel({
    required super.id,
    required super.jamMasuk,
    required super.jamKeluar,
    required super.batasJamMasuk,
    required super.startOvertime,
  });

  factory AturanJamModel.fromJson(Map<String, dynamic> json) {
    return AturanJamModel(
      id: json['id'] ?? 0,
      jamMasuk: json['jam_masuk'] ?? '',
      jamKeluar: json['jam_keluar'] ?? '',
      batasJamMasuk: json['batas_jam_masuk'] ?? '',
      startOvertime: json['start_overtime'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jam_masuk': jamMasuk,
      'jam_keluar': jamKeluar,
      'batas_jam_masuk': batasJamMasuk,
      'start_overtime': startOvertime,
    };
  }
}

class TodayAttendanceModel extends TodayAttendance {
  const TodayAttendanceModel({
    required super.success,
    required super.message,
    super.attendance,
    super.rules,
    required super.canCheckIn,
    required super.canCheckOut,
  });

  factory TodayAttendanceModel.fromJson(Map<String, dynamic> json) {
    return TodayAttendanceModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      attendance: json['data'] != null 
          ? AttendanceModel.fromJson(json['data'])
          : null,
      rules: json['rules'] != null 
          ? AturanJamModel.fromJson(json['rules'])
          : null,
      canCheckIn: json['can_check_in'] ?? false,
      canCheckOut: json['can_check_out'] ?? false,
    );
  }
}