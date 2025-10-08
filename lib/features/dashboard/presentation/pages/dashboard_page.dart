import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/dashboard_bloc.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/attendance_log_list.dart';
import '../widgets/attendance_summary_widget.dart';
import '../widgets/today_attendance_status_widget.dart';
import '../../../../injection_container.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DashboardBloc>()..add(GetDashboardDataEvent()),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1976D2), // blue 700
            Color(0xFF42A5F5), // blue 400
            Color(0xFFE3F2FD), // light background
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 🧭 Header section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        tooltip: "Refresh Data",
                        onPressed: () {
                          context.read<DashboardBloc>().add(GetDashboardDataEvent());
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        tooltip: "Logout",
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 💠 Content
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0, -2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.blue));
                    } else if (state is DashboardError) {
                      return _buildErrorState(context, state.message);
                    } else if (state is DashboardLoaded) {
                      return RefreshIndicator(
                        color: Colors.blue[700],
                        onRefresh: () async {
                          context.read<DashboardBloc>().add(GetDashboardDataEvent());
                        },
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DashboardHeader(
                                username: state.dashboardData.username,
                                department: state.dashboardData.department,
                                profilePicture: state.dashboardData.profilePicture,
                                photoUrl: state.dashboardData.photoUrl,
                              ),
                              const SizedBox(height: 24),
                              TodayAttendanceStatusWidget(
                                todayAttendance: state.dashboardData.todayAttendance,
                              ),
                              const SizedBox(height: 24),
                              AttendanceSummaryWidget(
                                monthlySummary: state.dashboardData.monthlySummary,
                                weeklySummary: state.dashboardData.weeklySummary,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Riwayat Absensi Terbaru',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              const SizedBox(height: 16),
                              AttendanceLogList(
                                attendanceLogs: state.dashboardData.attendanceLog,
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: Text(
                        'Welcome to Dashboard 👋',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<DashboardBloc>().add(GetDashboardDataEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
