import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// CustomPainter that draws the simple droid face shown on the Live Session card.
class DroidFacePainter extends CustomPainter {
  const DroidFacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primaryGreenDark;

    // Head — rounded square
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.05, size.width, size.height * 0.75),
      Radius.circular(size.width * 0.18),
    );
    canvas.drawRRect(headRect, paint..color = AppColors.primaryGreenDark);

    // Antenna
    final antennaPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width / 2, size.height * 0.05),
      Offset(size.width / 2, 0),
      antennaPaint,
    );
    canvas.drawCircle(
      Offset(size.width / 2, 0),
      3,
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );

    // Eyes
    final eyePaint = Paint()..color = Colors.white;
    final eyeY = size.height * 0.35;
    canvas.drawCircle(Offset(size.width * 0.32, eyeY), size.width * 0.1, eyePaint);
    canvas.drawCircle(Offset(size.width * 0.68, eyeY), size.width * 0.1, eyePaint);

    // Eye pupils
    final pupilPaint = Paint()..color = AppColors.primaryGreenDark;
    canvas.drawCircle(Offset(size.width * 0.32, eyeY), size.width * 0.05, pupilPaint);
    canvas.drawCircle(Offset(size.width * 0.68, eyeY), size.width * 0.05, pupilPaint);

    // Mouth — flat line (neutral expression)
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.6),
      Offset(size.width * 0.7, size.height * 0.6),
      mouthPaint,
    );

    // Ear stubs
    final earPaint = Paint()..color = AppColors.primaryGreenDark.withValues(alpha: 0.8);
    canvas.drawCircle(Offset(0, size.height * 0.45), size.width * 0.06, earPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.45), size.width * 0.06, earPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Live pulsing dot for "LIVE SESSION".
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key});

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.scale(
        scale: _scale.value,
        child: Opacity(
          opacity: _opacity.value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.liveRed,
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
