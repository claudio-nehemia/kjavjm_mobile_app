import 'package:equatable/equatable.dart';

class Attendance extends Equatable {
  final int id;
  final int userId;
  final String tanggal;
  final String status;
  final String? lateReason;
  final String? photoUrl;
  final String? checkIn;
  final String? checkOut;
  final String? documentation;
  final String? latitude;
  final String? longitude;
  final String? location;

  const Attendance({
    required this.id,
    required this.userId,
    required this.tanggal,
    required this.status,
    this.lateReason,
    this.photoUrl,
    this.checkIn,
    this.checkOut,
    this.documentation,
    this.latitude,
    this.longitude, 
    this.location,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        tanggal,
        status,
        lateReason,
        photoUrl,
        checkIn,
        checkOut,
        documentation,
        latitude,
        longitude,
        location,
      ];
}

class AturanJam extends Equatable {
  final int id;
  final String jamMasuk;
  final String jamKeluar;
  final String batasJamMasuk;
  final String startOvertime;

  const AturanJam({
    required this.id,
    required this.jamMasuk,
    required this.jamKeluar,
    required this.batasJamMasuk,
    required this.startOvertime,
  });

  @override
  List<Object> get props => [
        id,
        jamMasuk,
        jamKeluar,
        batasJamMasuk,
        startOvertime,
      ];
}

class TodayAttendance extends Equatable {
  final bool success;
  final String message;
  final Attendance? attendance;
  final AturanJam? rules;
  final bool canCheckIn;
  final bool canCheckOut;

  const TodayAttendance({
    required this.success,
    required this.message,
    this.attendance,
    this.rules,
    required this.canCheckIn,
    required this.canCheckOut,
  });

  @override
  List<Object?> get props => [
        success,
        message,
        attendance,
        rules,
        canCheckIn,
        canCheckOut,
      ];
}