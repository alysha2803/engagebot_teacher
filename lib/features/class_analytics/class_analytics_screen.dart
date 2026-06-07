import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/app_colors.dart';
import '../../data/mock/mock_data_service.dart';
import '../../data/models/student_model.dart';
import '../../shared/widgets/shared_widgets.dart';
import '../dashboard/widgets/ai_recommendation_card.dart';

/// Class Analytics screen — pushed from Dashboard or Classes when a class is tapped.
/// No bottom navigation bar (outside ShellRoute).
class ClassAnalyticsScreen extends StatelessWidget {
  final String classCode;

  const ClassAnalyticsScreen({super.key, required this.classCode});

  @override
  Widget build(BuildContext context) {
    final classes = MockDataService.getClasses();
    final cls = classes.firstWhere(
      (c) => c.code == classCode,
      orElse: () => classes.first,
    );
    final roster = MockDataService.getRosterForClass(cls.code);
    final engagement = MockDataService.getClassEngagement(cls.code);
    final aiRec = MockDataService.getAIRecommendation();
    final onlineCount = roster.where((s) => s.status == 'engaged').length;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.cardWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left,
              color: AppColors.textPrimary, size: 28),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/dashboard');
            }
          },
        ),
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cls.code,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              cls.subject,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: AppColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Engagement Overview ────────────────────────────────────────
            _ClassEngagementCard(
              percentage: engagement['percentage'] as int,
              trend: engagement['trend'] as String,
              sessionMinutes: engagement['sessionMinutes'] as int,
              studentCount: cls.studentCount,
              onlineCount: onlineCount,
              isOnline: cls.isOnline,
            ),

            const SizedBox(height: 16),

            // ── AI Recommendation ──────────────────────────────────────────
            AIRecommendationCard(
              text: aiRec['text'] as String,
              highlightWord: aiRec['highlightWord'] as String,
              actionLabel: aiRec['action'] as String,
              onApply: () {},
            ),

            const SizedBox(height: 24),

            // ── Class Roster ───────────────────────────────────────────────
            SectionHeader(
              title: 'Class Roster',
              trailing: Text(
                '$onlineCount Online',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 12),

            AppCard(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.85,
                ),
                itemCount: roster.length,
                itemBuilder: (context, index) {
                  final student = roster[index];
                  return _StudentTile(
                    student: student,
                    onTap: () =>
                        context.push('/students/${student.id}'),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Engagement Overview Card
// ---------------------------------------------------------------------------

class _ClassEngagementCard extends StatelessWidget {
  final int percentage;
  final String trend;
  final int sessionMinutes;
  final int studentCount;
  final int onlineCount;
  final bool isOnline;

  const _ClassEngagementCard({
    required this.percentage,
    required this.trend,
    required this.sessionMinutes,
    required this.studentCount,
    required this.onlineCount,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final trendUp = trend.startsWith('+');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live / Offline badge
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.liveRed : Colors.white54,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isOnline ? 'LIVE SESSION' : 'OFFLINE',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Percentage + trend
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      trendUp ? Icons.trending_up : Icons.trending_down,
                      size: 16,
                      color: trendUp ? Colors.greenAccent : Colors.redAccent,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      trend,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            trendUp ? Colors.greenAccent : Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Overall Engagement',
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // Meta row
          Row(
            children: [
              const Icon(Icons.people_outline, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '$onlineCount / $studentCount students online',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.access_time, size: 14, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                '${sessionMinutes}m session',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Student Tile (same visual style as dashboard roster)
// ---------------------------------------------------------------------------

class _StudentTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentTile({required this.student, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.sageLight,
                child: Text(
                  student.name.isNotEmpty ? student.name[0] : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: -2,
                child: StatusDot(status: student.status, size: 12),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
