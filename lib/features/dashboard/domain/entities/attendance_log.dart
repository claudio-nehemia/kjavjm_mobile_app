import 'package:equatable/equatable.dart';

class AttendanceLog extends Equatable {
  final int? id;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String? status;
  final String? notes;

  const AttendanceLog({
    this.id,
    this.checkIn,
    this.checkOut,
    this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [id, checkIn, checkOut, status, notes];
}