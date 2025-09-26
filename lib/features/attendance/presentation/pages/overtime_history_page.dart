import 'package:flutter/material.dart';
import '../../../overtime/data/services/overtime_service.dart';
import '../../../overtime/domain/entities/overtime.dart';
import '../../../../injection_container.dart';
import '../../../../shared/constants/app_constants.dart';

class OvertimeHistoryPage extends StatefulWidget {
  const OvertimeHistoryPage({super.key});

  @override
  State<OvertimeHistoryPage> createState() => _OvertimeHistoryPageState();
}

class _OvertimeHistoryPageState extends State<OvertimeHistoryPage> {
  final OvertimeService _overtimeService = sl<OvertimeService>();
  List<Overtime> _overtimes = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadOvertimeData();
  }

  Future<void> _loadOvertimeData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final overtimes = await _overtimeService.getOvertimeData();
      
      setState(() {
        _overtimes = overtimes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Lembur'),
        actions: [
          IconButton(
            onPressed: _loadOvertimeData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat data',
                        style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage,
                        style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOvertimeData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _overtimes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time_filled, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data lembur',
                            style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Riwayat waktu lembur akan muncul di sini',
                            style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOvertimeData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _overtimes.length,
                        itemBuilder: (context, index) {
                          final overtime = _overtimes[index];
                          return _buildOvertimeCard(overtime);
                        },
                      ),
                    ),
    );
  }

  Widget _buildOvertimeCard(Overtime overtime) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 16, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Lembur',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (overtime.durationHours > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      overtime.durationDisplay,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.orange[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (overtime.date != null) ...[
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    overtime.date!,
                    style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (overtime.startTime != null && overtime.endTime != null) ...[
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${overtime.startTime} - ${overtime.endTime}',
                    style: AppTextStyles.body2,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (overtime.reason != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      overtime.reason!,
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (overtime.createdAt != null) ...[
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Dicatat: ${_formatDate(overtime.createdAt!)}',
                    style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}