import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/class_model.dart';
import '../providers/classes_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────

class ClassSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback onFilter;

  const ClassSearchBar({
    super.key,
    required this.onChanged,
    required this.onFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(fontSize: 14, color: context.colorOnCard),
        decoration: InputDecoration(
          hintText: 'Search students or classes...',
          hintStyle: TextStyle(color: context.colorMuted, fontSize: 14),
          prefixIcon:
              Icon(Icons.search, color: context.colorMuted, size: 20),
          suffixIcon: GestureDetector(
            onTap: onFilter,
            child: const Icon(Icons.tune,
                color: AppColors.primaryGreen, size: 20),
          ),
          filled: true,
          fillColor: context.colorCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Periods / Students segmented toggle
// ─────────────────────────────────────────────────────────────────────────────

class PeriodRosterToggle extends StatelessWidget {
  final bool isPeriods;
  final ValueChanged<bool> onToggle;

  const PeriodRosterToggle({
    super.key,
    required this.isPeriods,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorChipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _Tab(
            label: 'Periods',
            isSelected: isPeriods,
            onTap: () => onToggle(true),
          ),
          _Tab(
            label: 'Students',
            isSelected: !isPeriods,
            onTap: () => onToggle(false),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color:
                isSelected ? context.colorCard : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? AppColors.cardShadow : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: isSelected
                    ? context.colorOnCard
                    : context.colorMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2-column class grid (Periods tab)
// ─────────────────────────────────────────────────────────────────────────────

class ClassGrid extends StatelessWidget {
  final List<ClassModel> classes;
  final void Function(ClassModel cls) onTap;

  const ClassGrid({super.key, required this.classes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No classes found',
            style: TextStyle(color: context.colorMuted),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: classes.length,
      itemBuilder: (context, index) =>
          ClassCard(cls: classes[index], onTap: () => onTap(classes[index])),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Individual class card
// ─────────────────────────────────────────────────────────────────────────────

class ClassCard extends StatelessWidget {
  final ClassModel cls;
  final VoidCallback onTap;

  const ClassCard({super.key, required this.cls, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isOnline = cls.isOnline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: isOnline
                      ? context.colorIconBg
                      : context.colorBorder.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  cls.status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isOnline
                        ? AppColors.primaryGreen
                        : context.colorMuted,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colorIconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              cls.code,
              style: TextStyle(
                fontSize: 11,
                color: context.colorMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              cls.subject,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: context.colorOnCard,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 14,
                  color: context.colorMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${cls.studentCount} Students',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.colorMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Student Attention List (Students tab)
// ─────────────────────────────────────────────────────────────────────────────

class StudentAttentionList extends StatelessWidget {
  final List<StudentWithClass> students;
  final void Function(StudentWithClass sw) onTap;

  const StudentAttentionList({
    super.key,
    required this.students,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'No students found',
            style: TextStyle(color: context.colorMuted),
          ),
        ),
      );
    }

    final needsAttention =
        students.where((s) => s.student.status != 'engaged').toList();
    final engaged =
        students.where((s) => s.student.status == 'engaged').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (needsAttention.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.flag_rounded,
            label: 'Needs Attention',
            count: needsAttention.length,
            iconColor: AppColors.liveRed,
          ),
          const SizedBox(height: 8),
          ...needsAttention.map(
            (sw) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StudentRow(sw: sw, onTap: () => onTap(sw)),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (engaged.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.check_circle_outline,
            label: 'Engaged',
            count: engaged.length,
            iconColor: AppColors.successGreen,
          ),
          const SizedBox(height: 8),
          ...engaged.map(
            (sw) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _StudentRow(sw: sw, onTap: () => onTap(sw)),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color iconColor;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: context.colorOnCard,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: context.colorIconBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }
}

class _StudentRow extends StatelessWidget {
  final StudentWithClass sw;
  final VoidCallback onTap;

  const _StudentRow({required this.sw, required this.onTap});

  Color get _statusColor => switch (sw.student.status) {
        'flagged' => AppColors.liveRed,
        'distracted' => AppColors.warningAmber,
        _ => AppColors.successGreen,
      };

  String get _statusLabel {
    final s = sw.student.status;
    return s[0].toUpperCase() + s.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colorCard,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppColors.cardShadow,
          border: Border(
            left: BorderSide(color: _statusColor, width: 4),
          ),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.colorAvatarBg,
              child: Text(
                sw.student.name.isNotEmpty
                    ? sw.student.name[0]
                    : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sw.student.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: context.colorOnCard,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sw.classCode,
                    style: TextStyle(
                      fontSize: 12,
                      color: context.colorSubtle,
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: _statusColor,
                ),
              ),
            ),

            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: context.colorMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Droid Insights section
// ─────────────────────────────────────────────────────────────────────────────

// TODO: Replace with droid insights API
class DroidInsightsSection extends StatelessWidget {
  final String title;
  final String description;

  const DroidInsightsSection({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.info_outline,
                size: 16, color: context.colorSubtle),
            const SizedBox(width: 6),
            Text(
              'Droid Insights',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: context.colorOnCard,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.colorCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colorIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.primaryGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: context.colorOnCard,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colorSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
