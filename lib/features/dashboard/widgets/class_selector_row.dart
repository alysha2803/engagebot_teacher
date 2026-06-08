import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';
import '../../../data/models/class_model.dart';

/// Horizontal scrollable row of class selector chips.
class ClassSelectorRow extends StatelessWidget {
  final List<ClassModel> classes;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const ClassSelectorRow({
    super.key,
    required this.classes,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: classes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final cls = classes[index];
          final isSelected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryGreen
                    : context.colorCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryGreen
                      : context.colorBorder,
                ),
                boxShadow: isSelected ? AppColors.cardShadow : [],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    cls.code,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white70
                          : context.colorMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cls.subject,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : context.colorOnCard,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
