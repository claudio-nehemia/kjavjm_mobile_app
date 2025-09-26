import 'package:flutter/material.dart';
import '../../../leave/data/services/leave_service.dart';
import '../../../leave/domain/entities/leave_approval.dart';
import '../../../../injection_container.dart';
import '../../../../shared/constants/app_constants.dart';

class LeaveHistoryPage extends StatefulWidget {
  const LeaveHistoryPage({super.key});

  @override
  State<LeaveHistoryPage> createState() => _LeaveHistoryPageState();
}

class _LeaveHistoryPageState extends State<LeaveHistoryPage> {
  final LeaveService _leaveService = sl<LeaveService>();
  List<LeaveApproval> _leaves = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLeaveData();
  }

  Future<void> _loadLeaveData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });
      
      final leaves = await _leaveService.getLeaveData();
      
      setState(() {
        _leaves = leaves;
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
        title: const Text('Riwayat Izin'),
        actions: [
          IconButton(
            onPressed: _loadLeaveData,
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
                        onPressed: _loadLeaveData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _leaves.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada data izin',
                            style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Riwayat pengajuan izin akan muncul di sini',
                            style: AppTextStyles.body2.copyWith(color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadLeaveData,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _leaves.length,
                        itemBuilder: (context, index) {
                          final leave = _leaves[index];
                          return _buildLeaveCard(leave);
                        },
                      ),
                    ),
    );
  }

  Widget _buildLeaveCard(LeaveApproval leave) {
    Color statusColor;
    IconData statusIcon;
    
    if (leave.isPending) {
      statusColor = AppColors.warning;
      statusIcon = Icons.schedule;
    } else if (leave.isApproved) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.cancel;
    }

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
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        leave.statusDisplay,
                        style: AppTextStyles.caption.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (leave.type != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                    ),
                    child: Text(
                      leave.typeDisplay,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (leave.startDate != null && leave.endDate != null) ...[
              Row(
                children: [
                  Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    leave.startDate == leave.endDate 
                        ? leave.startDate!
                        : '${leave.startDate} - ${leave.endDate}',
                    style: AppTextStyles.body2.copyWith(color: Colors.grey[600]),
                  ),
                  if (leave.totalDays != null && leave.totalDays! > 1) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(${leave.totalDays} hari)',
                      style: AppTextStyles.caption.copyWith(color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (leave.leaveReason != null) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      leave.leaveReason!,
                      style: AppTextStyles.body2,
                    ),
                  ),
                ],
              ),
            ],
            
            if (leave.createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(
                    'Diajukan: ${_formatDate(leave.createdAt!)}',
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