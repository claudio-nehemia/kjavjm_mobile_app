import '../../domain/entities/attendance_log.dart';

class AttendanceLogModel extends AttendanceLog {
  const AttendanceLogModel({
    super.id,
    super.checkIn,
    super.checkOut,
    super.status,
    super.notes,
  });

  factory AttendanceLogModel.fromJson(Map<String, dynamic> json) {
    return AttendanceLogModel(
      id: json['id'],
      checkIn: _parseDateTime(json['check_in']),
      checkOut: _parseDateTime(json['check_out']),
      status: json['status'],
      notes: json['notes'],
    );
  }

  static DateTime? _parseDateTime(dynamic timeData) {
    if (timeData == null) return null;
    
    try {
      String timeStr = timeData.toString();
      
      // Jika sudah format datetime lengkap
      if (timeStr.contains('T') || timeStr.contains(' ')) {
        return DateTime.parse(timeStr);
      }
      
      // Jika hanya format time (HH:mm:ss), gabungkan dengan tanggal hari ini
      if (RegExp(r'^\d{2}:\d{2}:\d{2}$').hasMatch(timeStr)) {
        final today = DateTime.now();
        final timeParts = timeStr.split(':');
        return DateTime(
          today.year,
          today.month,
          today.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
          int.parse(timeParts[2]),
        );
      }
      
      return null;
    } catch (e) {
      print('Error parsing datetime: $timeData - $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'check_in': checkIn?.toIso8601String(),
      'check_out': checkOut?.toIso8601String(),
      'status': status,
      'notes': notes,
    };
  }
}