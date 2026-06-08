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
        'distracted' => AppColors.warningAmber,
        'flagged' => AppColors.liveRed,
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
        border: Border.all(
          color: context.colorCard,
          width: 1.5,
        ),
      ),
    );
  }
}

/// Reusable pill/chip with rounded border.
class SageChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color textColor;
  final double fontSize;

  const SageChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor = AppColors.primaryGreen,
    this.fontSize = 11,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colorIconBg,
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: context.colorOnCard,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// EngageBot robot mascot drawn with a CustomPainter.
/// Matches the robot illustration used on the splash and login screens.
class RobotMascot extends StatelessWidget {
  final Color color;
  final double size;

  const RobotMascot({super.key, required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 1.15,
      child: CustomPaint(painter: _RobotPainter(color: color)),
    );
  }
}

class _RobotPainter extends CustomPainter {
  final Color color;
  const _RobotPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final sw = size.width * 0.052;
    final stroke = Paint()
      ..color = color
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..color = color..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;

    // Body
    canvas.drawRRect(
      RRect.fromLTRBR(w * 0.09, h * 0.17, w * 0.91, h * 0.90,
          Radius.circular(w * 0.20)),
      stroke,
    );

    // Antenna
    canvas.drawLine(
        Offset(w * 0.50, h * 0.17), Offset(w * 0.50, h * 0.06), stroke);
    final xPaint = Paint()
      ..color = color
      ..strokeWidth = sw * 0.85
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.42, h * 0.00), Offset(w * 0.58, h * 0.10), xPaint);
    canvas.drawLine(
        Offset(w * 0.58, h * 0.00), Offset(w * 0.42, h * 0.10), xPaint);

    // Left eye (filled circle)
    canvas.drawCircle(Offset(w * 0.34, h * 0.40), w * 0.07, fill);

    // Right eye (wink arc)
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.58, h * 0.37)
        ..quadraticBezierTo(w * 0.66, h * 0.44, w * 0.74, h * 0.37),
      stroke,
    );

    // Smile
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.30, h * 0.55)
        ..quadraticBezierTo(w * 0.50, h * 0.68, w * 0.70, h * 0.55),
      stroke,
    );

    // Chest diamond
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.50, h * 0.71)
        ..lineTo(w * 0.60, h * 0.79)
        ..lineTo(w * 0.50, h * 0.87)
        ..lineTo(w * 0.40, h * 0.79)
        ..close(),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _RobotPainter old) => old.color != color;
}

/// A standard card with rounded corners and subtle shadow.
/// Defaults to the theme surface colour; pass [color] to override.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? context.colorCard,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: AppColors.cardShadow,
      ),
      child: child,
    );
  }
}
