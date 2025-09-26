import 'package:flutter/material.dart';
import '../../domain/entities/dashboard_data.dart';

class AttendanceSummaryWidget extends StatelessWidget {
  final AttendanceSummary monthlySummary;
  final AttendanceSummary weeklySummary;

  const AttendanceSummaryWidget({
    super.key,
    required this.monthlySummary,
    required this.weeklySummary,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Ringkasan Bulanan
        _buildSummarySection(
          title: 'Ringkasan Kehadiran Bulan Ini',
          summary: monthlySummary,
        ),
        const SizedBox(height: 16),
        // Ringkasan Mingguan
        _buildSummarySection(
          title: 'Ringkasan Kehadiran Minggu Ini',
          summary: weeklySummary,
        ),
      ],
    );
  }

  Widget _buildSummarySection({
    required String title,
    required AttendanceSummary summary,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  title: 'Hadir',
                  count: summary.hadir,
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  title: 'Terlambat',
                  count: summary.terlambat,
                  color: Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  title: 'Izin',
                  count: summary.izin,
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  title: 'Absen',
                  count: summary.absen,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required String title,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}