class MonthlyStatistics {
  final int month;
  final String monthName;
  final int totalDays;
  final int presentDays;
  final int lateDays;
  final int leaveDays;
  final int absentDays;

  const MonthlyStatistics({
    required this.month,
    required this.monthName,
    required this.totalDays,
    required this.presentDays,
    required this.lateDays,
    required this.leaveDays,
    required this.absentDays,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyStatistics &&
          runtimeType == other.runtimeType &&
          month == other.month &&
          monthName == other.monthName &&
          totalDays == other.totalDays &&
          presentDays == other.presentDays &&
          lateDays == other.lateDays &&
          leaveDays == other.leaveDays &&
          absentDays == other.absentDays;

  @override
  int get hashCode =>
      month.hashCode ^
      monthName.hashCode ^
      totalDays.hashCode ^
      presentDays.hashCode ^
      lateDays.hashCode ^
      leaveDays.hashCode ^
      absentDays.hashCode;

  @override
  String toString() {
    return 'MonthlyStatistics{month: $month, monthName: $monthName, totalDays: $totalDays, presentDays: $presentDays, lateDays: $lateDays, leaveDays: $leaveDays, absentDays: $absentDays}';
  }
}