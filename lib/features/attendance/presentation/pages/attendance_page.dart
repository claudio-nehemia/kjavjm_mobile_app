import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/attendance.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_state.dart';
import '../bloc/attendance_event.dart';
import '../widgets/user_info_card.dart';
import '../widgets/attendance_action_card.dart';
import '../widgets/recent_attendance_list.dart';
import '../../../../injection_container.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../../core/mixins/auto_refresh_mixin.dart';
import '../../../../core/services/location_service.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<AttendanceBloc>()..add(GetTodayAttendanceEvent()),
      child: const AttendanceView(),
    );
  }
}

class AttendanceView extends StatefulWidget {
  const AttendanceView({super.key});

  @override
  State<AttendanceView> createState() => _AttendanceViewState();
}

class _AttendanceViewState extends State<AttendanceView> with AutoRefreshMixin {
  final LocationService _locationService = sl<LocationService>();

  @override
  void initState() {
    super.initState();
    startAutoRefresh();
  }

  @override
  void onAutoRefresh() {
    // Refresh attendance data
    context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
  }

  Future<Map<String, String>?> _getLocation() async {
    try {
      final locationData = await _locationService.getLocationWithAddress();
      return {
        'latitude': locationData['latitude'],
        'longitude': locationData['longitude'],
        'location': locationData['location'],
      };
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mendapatkan lokasi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                action: SnackBarAction(
                  label: 'OK',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<AttendanceBloc>().add(GetTodayAttendanceEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    UserInfoCard(
                      photoUrl: state is AttendanceLoaded ? state.photoUrl : null,
                      username: state is AttendanceLoaded ? state.username : 'User',
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Last Attendance Info (including location)
                    if (state is AttendanceLoaded && state.todayAttendance.attendance != null) ...[
                      _buildLastAttendanceInfo(state.todayAttendance.attendance!),
                      const SizedBox(height: AppSizes.paddingLarge),
                    ],
                    
                    // Status dan Action Cards
                    if (state is AttendanceLoaded) ...[
                      _buildAttendanceActions(context, state),
                      const SizedBox(height: AppSizes.paddingLarge),
                    ],
                  
                    // Recent Attendance
                    const Text(
                      'Riwayat Absensi Terakhir',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    const RecentAttendanceList(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAttendanceActions(BuildContext context, AttendanceLoaded state) {
    final now = DateTime.now();
    final todayAttendance = state.todayAttendance;
    
    final canCheckOut = _canCheckOut(now, todayAttendance);
    
    return Column(
      children: [
        // Check In Card
        AttendanceActionCard(
          title: 'Absensi Pagi',
          subtitle: 'Jam masuk: ${todayAttendance.rules?.jamMasuk ?? "-"}',
          icon: Icons.wb_sunny,
          iconColor: AppColors.warning,
          isEnabled: _canCheckIn(now, todayAttendance),
          onTap: () => _showCheckInDialog(context, todayAttendance),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        
        // Check Out Card
        AttendanceActionCard(
          title: 'Absensi Pulang',
          subtitle: 'Jam pulang: ${todayAttendance.rules?.jamKeluar ?? "-"}',
          icon: Icons.nightlight_round,
          iconColor: AppColors.info,
          isEnabled: canCheckOut,
          onTap: () => _showCheckOutDialog(context),
        ),
        const SizedBox(height: AppSizes.paddingMedium),
        
        // Overtime Card (if applicable)
        if (_canStartOvertime(now, todayAttendance))
          AttendanceActionCard(
            title: 'Data Lembur',
            subtitle: 'Mulai lembur: ${todayAttendance.rules?.startOvertime ?? "-"}',
            icon: Icons.access_time,
            iconColor: AppColors.danger,
            isEnabled: true,
            onTap: () => _showOvertimeDialog(context),
          )
        else if (todayAttendance.attendance != null && todayAttendance.attendance!.checkOut != null)
          // Show disabled overtime card if already checked out
          AttendanceActionCard(
            title: 'Data Lembur',
            subtitle: 'Sudah checkout - Tidak dapat input lembur',
            icon: Icons.access_time,
            iconColor: Colors.grey,
            isEnabled: false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Anda sudah melakukan checkout hari ini')),
            ),
          )
        else if (todayAttendance.attendance == null)
          // Show disabled overtime card if not checked in yet
          AttendanceActionCard(
            title: 'Data Lembur',
            subtitle: 'Harap checkin terlebih dahulu',
            icon: Icons.access_time,
            iconColor: Colors.grey,
            isEnabled: false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Harap melakukan checkin terlebih dahulu')),
            ),
          )
        else
          // Show overtime card when time hasn't reached start overtime
          AttendanceActionCard(
            title: 'Data Lembur',
            subtitle: 'Belum waktu lembur: ${todayAttendance.rules?.startOvertime ?? "-"}',
            icon: Icons.access_time,
            iconColor: Colors.grey,
            isEnabled: false,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Waktu lembur dimulai pada: ${todayAttendance.rules?.startOvertime ?? "-"}')),
            ),
          ),
      ],
    );
  }

  Widget _buildLastAttendanceInfo(Attendance attendance) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Absensi Hari Ini',
                style: AppTextStyles.body1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.paddingSmall),
          const Divider(),
          const SizedBox(height: AppSizes.paddingSmall),
          
          // Check In Time
          if (attendance.checkIn != null)
            _buildInfoRow(
              icon: Icons.login,
              label: 'Check In',
              value: attendance.checkIn!,
              color: AppColors.success,
            ),
          
          // Check Out Time
          if (attendance.checkOut != null) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow(
              icon: Icons.logout,
              label: 'Check Out',
              value: attendance.checkOut!,
              color: AppColors.danger,
            ),
          ],
          
          // Location
          if (attendance.location != null && attendance.location!.isNotEmpty) ...[
            const SizedBox(height: AppSizes.paddingSmall),
            _buildInfoRow(
              icon: Icons.location_on,
              label: 'Lokasi',
              value: attendance.location!,
              color: AppColors.info,
              isLocation: true,
            ),
          ],
          
          // Status
          const SizedBox(height: AppSizes.paddingSmall),
          _buildInfoRow(
            icon: Icons.check_circle,
            label: 'Status',
            value: _getStatusLabel(attendance.status),
            color: _getStatusColor(attendance.status),
          ),

        
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isLocation = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              if (isLocation)
                _buildLocationContent(value)
              else
                Text(
                  value,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocationContent(String location) {
    final isTooLong = location.length > 40;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          location,
          style: AppTextStyles.body2.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (isTooLong) ...[
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _showFullLocationDialog(location),
            child: Text(
              'Lihat Selengkapnya',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showFullLocationDialog(String location) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(
                Icons.location_on,
                color: AppColors.primary,
                size: 24,
              ),
              SizedBox(width: 8),
              Text('Lokasi Lengkap'),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              location,
              style: AppTextStyles.body2,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Tutup',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return 'Hadir';
      case 'late':
        return 'Terlambat';
      case 'leave':
        return 'Izin';
      case 'sick':
        return 'Sakit';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return AppColors.success;
      case 'late':
        return AppColors.warning;
      case 'leave':
      case 'sick':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }

  bool _canCheckIn(DateTime now, todayAttendance) {
    if (todayAttendance.attendance != null) return false; // Already checked in
    
    final rules = todayAttendance.rules;
    if (rules == null) return false;
    
    final jamMasuk = _parseTime(rules.jamMasuk);
    final jamKeluar = _parseTime(rules.jamKeluar);
    final currentTime = TimeOfDay.fromDateTime(now);
    
    return _isTimeAfterOrEqual(currentTime, jamMasuk) && 
           _isTimeBefore(currentTime, jamKeluar);
  }

  bool _canCheckOut(DateTime now, todayAttendance) {
    print('DEBUG _canCheckOut - Starting check...');
    
    if (todayAttendance.attendance == null) {
      print('DEBUG _canCheckOut - FALSE: attendance is null');
      return false; // Must check in first
    }
    
    if (todayAttendance.attendance?.checkOut != null) {
      print('DEBUG _canCheckOut - FALSE: already checked out');
      return false; // Already checked out
    }
    
    final rules = todayAttendance.rules;
    if (rules == null) {
      print('DEBUG _canCheckOut - FALSE: rules is null');
      return false;
    }
    
    final jamKeluar = _parseTime(rules.jamKeluar);
    final startOvertime = _parseTime(rules.startOvertime);
    final currentTime = TimeOfDay.fromDateTime(now);
    
    // Debug logging
    print('Debug CheckOut - Current time: ${currentTime.hour}:${currentTime.minute}');
    print('Debug CheckOut - Jam keluar: ${jamKeluar.hour}:${jamKeluar.minute}');
    print('Debug CheckOut - Start overtime: ${startOvertime.hour}:${startOvertime.minute}');
    print('Debug CheckOut - Raw jamKeluar: ${rules.jamKeluar}');
    print('Debug CheckOut - Raw startOvertime: ${rules.startOvertime}');
    
    final afterJamKeluar = _isTimeAfterOrEqual(currentTime, jamKeluar);
    final beforeOvertime = _isTimeBefore(currentTime, startOvertime);
    
    print('Debug CheckOut - afterJamKeluar: $afterJamKeluar');
    print('Debug CheckOut - beforeOvertime: $beforeOvertime');
    
    // Simplified logic: allow check-out after jam keluar
    print('DEBUG _canCheckOut - RESULT: $afterJamKeluar');
    return afterJamKeluar;
    
    // Original complex logic (commented out for now)
    // return afterJamKeluar && beforeOvertime;
  }

  bool _canStartOvertime(DateTime now, todayAttendance) {
    // Check if user has already checked out
    final attendance = todayAttendance.attendance;
    if (attendance != null && attendance.checkOut != null) {
      // Already checked out, disable overtime
      return false;
    }
    
    // Check if user hasn't checked in yet
    if (attendance == null) {
      return false;
    }
    
    final rules = todayAttendance.rules;
    if (rules == null) return false;
    
    final startOvertime = _parseTime(rules.startOvertime);
    final currentTime = TimeOfDay.fromDateTime(now);
    
    return _isTimeAfterOrEqual(currentTime, startOvertime);
  }

  TimeOfDay _parseTime(String timeString) {
    // Handle both HH:mm and HH:mm:ss format, also handle HH.mm format
    String normalizedTime = timeString.replaceAll('.', ':');
    final parts = normalizedTime.split(':');
    
    try {
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      print('Error parsing time: $timeString, error: $e');
      // Return default time if parsing fails
      return const TimeOfDay(hour: 8, minute: 0);
    }
  }

  bool _isTimeAfterOrEqual(TimeOfDay current, TimeOfDay target) {
    return current.hour > target.hour || 
           (current.hour == target.hour && current.minute >= target.minute);
  }

  bool _isTimeBefore(TimeOfDay current, TimeOfDay target) {
    return current.hour < target.hour || 
           (current.hour == target.hour && current.minute < target.minute);
  }

  void _showCheckInDialog(BuildContext context, todayAttendance) {
    final now = DateTime.now();
    final rules = todayAttendance.rules;
    final jamMasuk = _parseTime(rules?.jamMasuk ?? '08:00:00');
    final batasJamMasuk = _parseTime(rules?.batasJamMasuk ?? '09:00:00');
    final currentTime = TimeOfDay.fromDateTime(now);
    
    if (_isTimeBefore(currentTime, jamMasuk)) {
      _showTimeRestrictionDialog(context, 'Belum saatnya absen masuk', 
          'Anda bisa absen masuk mulai pukul ${rules?.jamMasuk}');
      return;
    }
    
    final isLate = _isTimeAfterOrEqual(currentTime, batasJamMasuk);
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Pilih Status Kehadiran'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.check_circle, color: AppColors.success),
              title: Text(isLate ? 'Hadir (Terlambat)' : 'Hadir'),
              onTap: () async {
                Navigator.pop(dialogContext);
                
                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                // Get location
                final locationData = await _getLocation();
                
                // Hide loading
                if (mounted) Navigator.pop(context);
                
                if (locationData == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mendapatkan lokasi. Silakan coba lagi.')),
                    );
                  }
                  return;
                }
                
                if (isLate) {
                  _showDocumentationDialog(
                    context, 
                    'present',
                    latitude: locationData['latitude'],
                    longitude: locationData['longitude'],
                    location: locationData['location'],
                  );
                } else {
                  if (mounted) {
                    context.read<AttendanceBloc>().add(
                      CheckInEvent(
                        status: 'present',
                        documentation: null,
                        latitude: locationData['latitude'],
                        longitude: locationData['longitude'],
                        location: locationData['location'],
                      ),
                    );
                  }
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.sick, color: AppColors.warning),
              title: const Text('Izin'),
              onTap: () {
                Navigator.pop(dialogContext);
                _showLeaveDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCheckOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Pulang'),
        content: const Text('Apakah Anda yakin ingin absen pulang?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AttendanceBloc>().add(CheckOutEvent());
              // Show overtime notification if applicable
              _showOvertimeNotification(context);
            },
            child: const Text('Ya, Pulang'),
          ),
        ],
      ),
    );
  }

  void _showOvertimeNotification(BuildContext context) {
    // Check if it's overtime period
    final now = DateTime.now();
    final currentTime = TimeOfDay.fromDateTime(now);
    final startOvertimeTime = TimeOfDay(hour: 18, minute: 0); // Default 18:00
    
    if (_isTimeAfterOrEqual(currentTime, startOvertimeTime)) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Data lembur telah dicatat secara otomatis'),
              backgroundColor: AppColors.info,
              action: SnackBarAction(
                label: 'Lihat',
                onPressed: () {
                  // TODO: Navigate to overtime history
                },
              ),
            ),
          );
        }
      });
    }
  }

  void _showOvertimeDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    final TextEditingController notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Data Lembur'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Anda akan melakukan check-out dengan status lembur.',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                
                // Alasan Lembur
                const Text('Alasan Lembur:', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan alasan lembur...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                
                // Catatan Tambahan
                const Text('Catatan (Opsional):', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Catatan tambahan...',
                    contentPadding: EdgeInsets.all(12),
                  ),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                
                // Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informasi:',
                        style: TextStyle(fontWeight: FontWeight.w600, color: Colors.blue),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '• Data lembur akan dicatat otomatis\n• Status: Pending (menunggu approval)\n• Waktu lembur dihitung dari jam kerja normal',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              // Validasi
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(content: Text('Alasan lembur harus diisi')),
                );
                return;
              }
              
              Navigator.pop(dialogContext);
              
              // Show confirmation dialog
              _showOvertimeConfirmationDialog(
                context,
                reasonController.text.trim(),
                notesController.text.trim(),
              );
            },
            child: const Text('Lanjutkan'),
          ),
        ],
      ),
    );
  }

  void _showOvertimeConfirmationDialog(BuildContext context, String reason, String notes) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konfirmasi Check-out Lembur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin check-out dengan data lembur?'),
            const SizedBox(height: 12),
            Text('Alasan: $reason', style: const TextStyle(fontWeight: FontWeight.w500)),
            if (notes.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Catatan: $notes', style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              // Perform check-out with overtime data
              _performOvertimeCheckOut(context, reason, notes);
            },
            child: const Text('Ya, Check-out'),
          ),
        ],
      ),
    );
  }

  void _performOvertimeCheckOut(BuildContext context, String reason, String notes) {
    // Create check-out event with overtime data
    context.read<AttendanceBloc>().add(
      CheckOutWithOvertimeEvent(
        reason: reason,
        notes: notes.isEmpty ? null : notes,
      ),
    );
    
    // Show overtime notification
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Check-out berhasil! Data lembur telah dicatat.'),
            backgroundColor: AppColors.success,
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navigate to overtime history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fitur riwayat lembur akan segera tersedia')),
                );
              },
            ),
          ),
        );
      }
    });
  }

  void _showTimeRestrictionDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDocumentationDialog(
    BuildContext context, 
    String status,
    {String? latitude, String? longitude, String? location}
  ) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keterangan Terlambat'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan terlambat...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AttendanceBloc>().add(
                CheckInEvent(
                  status: status, 
                  documentation: controller.text,
                  latitude: latitude,
                  longitude: longitude,
                  location: location,
                ),
              );
            },
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(BuildContext context) {
    final TextEditingController reasonController = TextEditingController();
    String selectedLeaveType = 'sick';
    DateTime? startDate;
    DateTime? endDate;
    int totalDays = 1;
    PlatformFile? selectedDocument;
    
    void calculateTotalDays() {
      if (startDate != null && endDate != null) {
        totalDays = endDate!.difference(startDate!).inDays + 1;
      }
    }
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: const Text('Pengajuan Izin'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Jenis Izin
                  const Text('Jenis Izin:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedLeaveType,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'sick', child: Text('Sakit')),
                      DropdownMenuItem(value: 'personal', child: Text('Keperluan Pribadi')),
                      DropdownMenuItem(value: 'emergency', child: Text('Darurat')),
                      DropdownMenuItem(value: 'annual', child: Text('Cuti Tahunan')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedLeaveType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Tanggal Mulai
                  const Text('Tanggal Mulai:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: startDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          startDate = date;
                          if (endDate == null || endDate!.isBefore(date)) {
                            endDate = date;
                          }
                          calculateTotalDays();
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        startDate != null 
                            ? '${startDate!.day}/${startDate!.month}/${startDate!.year}'
                            : 'Pilih tanggal mulai',
                        style: TextStyle(
                          color: startDate != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Tanggal Selesai
                  const Text('Tanggal Selesai:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: startDate == null ? null : () async {
                      final date = await showDatePicker(
                        context: dialogContext,
                        initialDate: endDate ?? startDate!,
                        firstDate: startDate!,
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (date != null) {
                        setState(() {
                          endDate = date;
                          calculateTotalDays();
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: startDate == null ? Colors.grey[300]! : Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        endDate != null 
                            ? '${endDate!.day}/${endDate!.month}/${endDate!.year}'
                            : 'Pilih tanggal selesai',
                        style: TextStyle(
                          color: endDate != null ? Colors.black : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Total Hari
                  if (startDate != null && endDate != null)
                    Text(
                      'Total: $totalDays hari',
                      style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.blue),
                    ),
                  const SizedBox(height: 16),
                  
                  // Alasan
                  const Text('Alasan:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Masukkan alasan izin...',
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  
                  // Upload Dokumen
                  const Text('Dokumen Pendukung:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            try {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
                                allowMultiple: false,
                              );
                              
                              if (result != null) {
                                final file = result.files.first;
                                if (file.size > 2 * 1024 * 1024) { // 2MB
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(content: Text('Ukuran file maksimal 2MB')),
                                  );
                                  return;
                                }
                                setState(() {
                                  selectedDocument = file;
                                });
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Error memilih file: $e')),
                              );
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text(selectedDocument != null ? 'File Terpilih' : 'Pilih File'),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          selectedDocument != null 
                              ? 'File: ${selectedDocument!.name} (${(selectedDocument!.size / 1024).toStringAsFixed(1)} KB)'
                              : 'Format: JPG, PNG, PDF (Max: 2MB)',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validasi
                if (reasonController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Alasan izin harus diisi')),
                  );
                  return;
                }
                
                if (startDate == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Tanggal mulai harus dipilih')),
                  );
                  return;
                }
                
                if (endDate == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Tanggal selesai harus dipilih')),
                  );
                  return;
                }
                
                if (selectedDocument == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Dokumen pendukung harus dipilih')),
                  );
                  return;
                }
                
                Navigator.pop(dialogContext);
                
                // Show loading while getting location
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (ctx) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
                
                // Get location
                final locationData = await _getLocation();
                
                // Hide loading
                if (mounted) Navigator.pop(context);
                
                if (locationData == null) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mendapatkan lokasi. Silakan coba lagi.')),
                    );
                  }
                  return;
                }
                
                // Format date strings for API
                final startDateStr = '${startDate!.year}-${startDate!.month.toString().padLeft(2, '0')}-${startDate!.day.toString().padLeft(2, '0')}';
                final endDateStr = '${endDate!.year}-${endDate!.month.toString().padLeft(2, '0')}-${endDate!.day.toString().padLeft(2, '0')}';
                
                // Submit leave request with comprehensive data
                if (mounted) {
                  context.read<AttendanceBloc>().add(
                    CheckInWithLeaveEvent(
                      leaveReason: reasonController.text.trim(),
                      startDate: startDateStr,
                      endDate: endDateStr,
                      totalDays: totalDays,
                      type: selectedLeaveType,
                      document: selectedDocument!,
                      latitude: locationData['latitude'],
                      longitude: locationData['longitude'],
                      location: locationData['location'],
                    ),
                  );
                }
              },
              child: const Text('Ajukan Izin'),
            ),
          ],
        ),
      ),
    );
  }
}