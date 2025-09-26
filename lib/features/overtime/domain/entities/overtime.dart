class Overtime {
  final int? id;
  final int? userId;
  final String? date;
  final String? startTime;
  final String? endTime;
  final String? reason;
  final String? status; // Pending, Approved, Rejected
  final String? notes;
  final String? processedAt;
  final int? processedBy;
  final String? createdAt;
  final String? updatedAt;

  Overtime({
    this.id,
    this.userId,
    this.date,
    this.startTime,
    this.endTime,
    this.reason,
    this.status,
    this.notes,
    this.processedAt,
    this.processedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Overtime.fromJson(Map<String, dynamic> json) {
    return Overtime(
      id: json['id'],
      userId: json['user_id'],
      date: json['date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      reason: json['reason'],
      status: json['status'],
      notes: json['notes'],
      processedAt: json['processed_at'],
      processedBy: json['processed_by'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'reason': reason,
      'status': status,
      'notes': notes,
      'processed_at': processedAt,
      'processed_by': processedBy,
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

  // Calculate overtime duration in hours
  double get durationHours {
    if (startTime == null || endTime == null) return 0.0;
    
    try {
      final start = DateTime.parse('${date ?? DateTime.now().toString().split(' ')[0]} $startTime');
      final end = DateTime.parse('${date ?? DateTime.now().toString().split(' ')[0]} $endTime');
      final difference = end.difference(start);
      return difference.inMinutes / 60.0;
    } catch (e) {
      return 0.0;
    }
  }

  String get durationDisplay {
    final hours = durationHours;
    if (hours >= 1) {
      return '${hours.toStringAsFixed(1)} jam';
    } else {
      return '${(hours * 60).toInt()} menit';
    }
  }
}