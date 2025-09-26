class LeaveApproval {
  final int? id;
  final int? userId;
  final int? attendanceId;
  final String? leaveReason;
  final String? status; // Pending, Approved, Rejected
  final String? startDate;
  final String? endDate;
  final int? totalDays;
  final String? type; // sick, personal, annual, emergency
  final String? document;
  final String? createdAt;
  final String? updatedAt;

  LeaveApproval({
    this.id,
    this.userId,
    this.attendanceId,
    this.leaveReason,
    this.status,
    this.startDate,
    this.endDate,
    this.totalDays,
    this.type,
    this.document,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveApproval.fromJson(Map<String, dynamic> json) {
    return LeaveApproval(
      id: json['id'],
      userId: json['user_id'],
      attendanceId: json['attendance_id'],
      leaveReason: json['leave_reason'],
      status: json['status'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      totalDays: json['total_days'],
      type: json['type'],
      document: json['document'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'attendance_id': attendanceId,
      'leave_reason': leaveReason,
      'status': status,
      'start_date': startDate,
      'end_date': endDate,
      'total_days': totalDays,
      'type': type,
      'document': document,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Helper methods
  bool get isPending => status == 'Pending';
  bool get isApproved => status == 'Approved';
  bool get isRejected => status == 'Rejected';

  String get statusDisplay {
    switch (status) {
      case 'Pending':
        return 'Menunggu';
      case 'Approved':
        return 'Disetujui';
      case 'Rejected':
        return 'Ditolak';
      default:
        return status ?? '';
    }
  }

  String get typeDisplay {
    switch (type) {
      case 'sick':
        return 'Sakit';
      case 'personal':
        return 'Pribadi';
      case 'annual':
        return 'Cuti Tahunan';
      case 'emergency':
        return 'Darurat';
      default:
        return type ?? '';
    }
  }
}