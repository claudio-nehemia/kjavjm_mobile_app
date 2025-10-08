import 'package:flutter/material.dart';
import '../../../../shared/constants/app_constants.dart';

class ModernStatsCard extends StatelessWidget {
  final List<StatItem> stats;

  const ModernStatsCard({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.05),
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: stats.asMap().entries.map((entry) {
          final index = entry.key;
          final stat = entry.value;
          final isLast = index == stats.length - 1;
          
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(stat),
                ),
                if (!isLast)
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey[300],
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatItem(StatItem stat) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: stat.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            stat.icon,
            color: stat.color,
            size: 28,
          ),
        ),
        const SizedBox(height: 12),
        TweenAnimationBuilder<int>(
          duration: const Duration(milliseconds: 1000),
          tween: IntTween(begin: 0, end: stat.value),
          builder: (context, value, child) {
            return Text(
              value.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: stat.color,
                letterSpacing: -0.5,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class StatItem {
  final IconData icon;
  final Color color;
  final int value;
  final String label;

  StatItem({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
}
