import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/class_model.dart';
import '../../../shared/widgets/shared_widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Search bar
// ─────────────────────────────────────────────────────────────────────────────
class ClassSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const ClassSearchBar({super.key, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'Search students or classes...',
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon:
              const Icon(Icons.search, color: AppColors.textMuted, size: 20),
          suffixIcon:
              const Icon(Icons.tune, color: AppColors.textMuted, size: 20),
          filled: true,
          fillColor: AppColors.cardWhite,
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
// Period / Roster segmented toggle
// ─────────────────────────────────────────────────────────────────────────────
class PeriodRosterToggle extends StatelessWidget {
  final bool isPeriods; // true = Periods selected
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
        color: const Color(0xFFF0F0EC),
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
            label: 'Roster',
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
            color: isSelected ? AppColors.cardWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected ? AppColors.cardShadow : [],
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2-column class grid
// ─────────────────────────────────────────────────────────────────────────────
class ClassGrid extends StatelessWidget {
  final List<ClassModel> classes;
  final void Function(ClassModel cls) onTap;

  const ClassGrid({super.key, required this.classes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No classes found',
            style: TextStyle(color: AppColors.textMuted),
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
          color: AppColors.cardWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Online/Offline badge top-right
            Align(
              alignment: Alignment.topRight,
              child: SageChip(
                label: cls.status,
                backgroundColor: isOnline
                    ? AppColors.sageLighter
                    : const Color(0xFFF3F4F6),
                textColor: isOnline
                    ? AppColors.primaryGreen
                    : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 4),

            // Clock icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.sageLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.schedule,
                color: AppColors.primaryGreen,
                size: 20,
              ),
            ),
            const SizedBox(height: 10),

            // Class code
            Text(
              cls.code,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),

            // Subject name
            Text(
              cls.subject,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Student count
            Row(
              children: [
                const Icon(
                  Icons.group_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  '${cls.studentCount} Students',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
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
        const Row(
          children: [
            Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
            SizedBox(width: 6),
            Text(
              'Droid Insights',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardWhite,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppColors.cardShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.sageLighter,
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
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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
