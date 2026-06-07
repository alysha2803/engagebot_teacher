import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/student_model.dart';
import '../../../shared/widgets/shared_widgets.dart';

/// White card containing the 3-column student avatar grid with status dots.
// TODO: Replace with live droid roster data
class ClassRosterSection extends StatelessWidget {
  final List<StudentModel> students;
  final int onlineCount;
  final void Function(StudentModel student) onStudentTap;
  final VoidCallback onManageTap;

  const ClassRosterSection({
    super.key,
    required this.students,
    required this.onlineCount,
    required this.onStudentTap,
    required this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: 'Class Roster '),
                  TextSpan(
                    text: '· $onlineCount Online',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Auto-refreshing',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Avatar grid card
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
            // +1 for the Manage cell
            itemCount: students.length + 1,
            itemBuilder: (context, index) {
              if (index == students.length) {
                return _ManageCell(onTap: onManageTap);
              }
              return _StudentAvatarTile(
                student: students[index],
                onTap: () => onStudentTap(students[index]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StudentAvatarTile extends StatelessWidget {
  final StudentModel student;
  final VoidCallback onTap;

  const _StudentAvatarTile({required this.student, required this.onTap});

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
              // Status dot bottom-right
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

class _ManageCell extends StatelessWidget {
  final VoidCallback onTap;

  const _ManageCell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.borderLight,
                width: 2,
                // Dashed border effect via custom painter would be ideal;
                // using a dotted style approximation here
              ),
              color: AppColors.backgroundLight,
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppColors.textMuted,
              size: 26,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Manage',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
