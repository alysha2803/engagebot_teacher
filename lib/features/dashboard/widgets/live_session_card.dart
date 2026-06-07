import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import 'droid_face_painter.dart';

/// Full-width olive-green card showing live session engagement data.
class LiveSessionCard extends StatelessWidget {
  final int percentage;
  final String trend;
  final int sessionMinutes;
  final String droidStatus;

  const LiveSessionCard({
    super.key,
    required this.percentage,
    required this.trend,
    required this.sessionMinutes,
    required this.droidStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left: engagement info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Live indicator
                const Row(
                  children: [
                    PulsingDot(),
                    SizedBox(width: 6),
                    Text(
                      'LIVE SESSION',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Large percentage
                Text(
                  '$percentage%',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Overall Engagement',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 16),

                // Pill chips row
                Row(
                  children: [
                    _PillChip(
                      icon: Icons.timer_outlined,
                      label: '${sessionMinutes}m',
                    ),
                    const SizedBox(width: 8),
                    _PillChip(
                      icon: Icons.trending_up,
                      label: trend,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Right: droid face + status badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                width: 88,
                height: 88,
                child: CustomPaint(painter: DroidFacePainter()),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreenDark,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'DROID: $droidStatus',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PillChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _PillChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
