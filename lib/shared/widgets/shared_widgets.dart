import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';

/// Reusable EngageBot logo icon widget used in AppBars.
class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(size * 0.25),
      ),
      child: Center(
        child: Icon(
          Icons.smart_toy_outlined,
          color: Colors.white,
          size: size * 0.6,
        ),
      ),
    );
  }
}

/// Coloured dot indicating student status.
class StatusDot extends StatelessWidget {
  final String status; // 'engaged' | 'distracted' | 'flagged'
  final double size;

  const StatusDot({super.key, required this.status, this.size = 10});

  Color get _color => switch (status) {
        'engaged' => AppColors.successGreen,
        'distracted' => AppColors.liveRed,
        'flagged' => AppColors.warningAmber,
        _ => AppColors.textMuted,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: _color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1.5),
      ),
    );
  }
}

/// Reusable pill/chip with rounded border.
class SageChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;

  const SageChip({
    super.key,
    required this.label,
    this.backgroundColor = AppColors.sageLight,
    this.textColor = AppColors.primaryGreen,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

/// Section header row: title on left, optional action widget on right.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// A standard white card with rounded corners and subtle shadow.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.cardWhite,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}
