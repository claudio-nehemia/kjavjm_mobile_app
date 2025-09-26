import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_state.dart';
import '../../domain/entities/attendance.dart';
import 'package:intl/intl.dart';

class RecentAttendanceList extends StatelessWidget {
  const RecentAttendanceList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AttendanceBloc, AttendanceState>(
      builder: (context, state) {
        if (state is AttendanceLoaded && state.recentAttendance != null) {
          final recentAttendance = state.recentAttendance!;
          
          if (recentAttendance.isEmpty) {
            return _buildEmptyState();
          }
          
          return Column(
            children: recentAttendance.map((attendance) => 
              _buildAttendanceItem(attendance)
            ).toList(),
          );
        }
        
        return _buildLoadingState();
      },
    );
  }

  Widget _buildAttendanceItem(Attendance attendance) {
    final statusColor = _getStatusColor(attendance.status);
    final statusText = _getStatusText(attendance.status);
    final checkInTime = attendance.checkIn;
    final checkOutTime = attendance.checkOut;
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSmall),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            // Date Section
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Text(
                    DateFormat('dd').format(DateTime.parse(attendance.tanggal)),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(DateTime.parse(attendance.tanggal)),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: AppSizes.paddingMedium),
            
            // Attendance Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        DateFormat('EEEE', 'id_ID').format(DateTime.parse(attendance.tanggal)),
                        style: AppTextStyles.body1.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  
                  // Time Information
                  Row(
                    children: [
                      if (checkInTime != null) ...[
                        Icon(Icons.login, size: 16, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          checkInTime.substring(0, 5) + ' WIB',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      
                      if (checkOutTime != null) ...[
                        Icon(Icons.logout, size: 16, color: AppColors.danger),
                        const SizedBox(width: 4),
                        Text(
                          checkOutTime.substring(0, 5) + ' WIB',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ] else if (checkInTime != null) ...[
                        Text(
                          attendance.status == 'Leave' ? 'Anda Izin' : 'Belum Pulang',
                          style: AppTextStyles.body2.copyWith(
                            color: attendance.status == 'Leave' ? AppColors.info : AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          children: [
            Icon(
              Icons.history,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: AppSizes.paddingSmall),
            Text(
              'Belum ada riwayat absensi',
              style: AppTextStyles.body1.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: const Padding(
        padding: EdgeInsets.all(AppSizes.paddingLarge),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'leave':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Tepat Waktu';
      case 'late':
        return 'Terlambat';
      case 'leave':
        return 'Izin';
      default:
        return status;
    }
  }
}