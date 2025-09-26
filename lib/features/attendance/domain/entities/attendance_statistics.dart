class AttendanceStatistics {
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int leaveDays;
  final int absentDays;
  final int overtimeDays;
  final double presentPercentage;
  final double latePercentage;
  final double leavePercentage;
  final double absentPercentage;

  const AttendanceStatistics({
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.leaveDays,
    required this.absentDays,
    required this.overtimeDays,
    required this.presentPercentage,
    required this.latePercentage,
    required this.leavePercentage,
    required this.absentPercentage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AttendanceStatistics &&
          runtimeType == other.runtimeType &&
          totalDays == other.totalDays &&
          presentDays == other.presentDays &&
          lateDays == other.lateDays &&
          leaveDays == other.leaveDays &&
          absentDays == other.absentDays &&
          overtimeDays == other.overtimeDays &&
          presentPercentage == other.presentPercentage &&
          latePercentage == other.latePercentage &&
          leavePercentage == other.leavePercentage &&
          absentPercentage == other.absentPercentage;

  @override
  int get hashCode =>
      totalDays.hashCode ^
      presentDays.hashCode ^
      lateDays.hashCode ^
      leaveDays.hashCode ^
      absentDays.hashCode ^
      overtimeDays.hashCode ^
      presentPercentage.hashCode ^
      latePercentage.hashCode ^
      leavePercentage.hashCode ^
      absentPercentage.hashCode;

  @override
  String toString() {
    return 'AttendanceStatistics{totalDays: $totalDays, presentDays: $presentDays, lateDays: $lateDays, leaveDays: $leaveDays, absentDays: $absentDays, overtimeDays: $overtimeDays, presentPercentage: $presentPercentage, latePercentage: $latePercentage, leavePercentage: $leavePercentage, absentPercentage: $absentPercentage}';
  }
}