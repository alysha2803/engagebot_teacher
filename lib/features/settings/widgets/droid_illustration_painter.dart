import 'package:flutter/material.dart';
import '../../../app/theme/app_colors.dart';

/// CustomPainter that draws a simple robot illustration for the Settings screen.
class DroidIllustrationPainter extends CustomPainter {
  const DroidIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bodyPaint = Paint()..color = AppColors.primaryGreen;
    final darkPaint = Paint()..color = AppColors.primaryGreenDark;
    final whitePaint = Paint()..color = Colors.white;
    final sagePaint = Paint()..color = AppColors.sageLight;

    final w = size.width;
    final h = size.height;

    // ── Body ──────────────────────────────────────────────────────────────
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.2, h * 0.28, w * 0.6, h * 0.45),
      Radius.circular(w * 0.12),
    );
    canvas.drawRRect(bodyRect, bodyPaint);

    // ── Head ──────────────────────────────────────────────────────────────
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.28, h * 0.08, w * 0.44, h * 0.22),
      Radius.circular(w * 0.1),
    );
    canvas.drawRRect(headRect, darkPaint);

    // Antenna base
    canvas.drawRect(
      Rect.fromLTWH(w * 0.48, h * 0.02, w * 0.04, h * 0.07),
      darkPaint,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.02), w * 0.04, sagePaint);

    // Eyes
    canvas.drawCircle(Offset(w * 0.39, h * 0.17), w * 0.06, whitePaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.17), w * 0.06, whitePaint);
    // Pupils
    canvas.drawCircle(Offset(w * 0.39, h * 0.17), w * 0.03, darkPaint);
    canvas.drawCircle(Offset(w * 0.61, h * 0.17), w * 0.03, darkPaint);

    // Mouth
    final mouthPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(w * 0.4, h * 0.22, w * 0.2, h * 0.06),
      0,
      3.14159,
      false,
      mouthPaint,
    );

    // ── Arms ──────────────────────────────────────────────────────────────
    final armRadius = Radius.circular(w * 0.06);
    // Left arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.32, w * 0.12, h * 0.25),
        armRadius,
      ),
      darkPaint,
    );
    // Right arm
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.8, h * 0.32, w * 0.12, h * 0.25),
        armRadius,
      ),
      darkPaint,
    );

    // ── Legs ──────────────────────────────────────────────────────────────
    final legRadius = Radius.circular(w * 0.05);
    // Left leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.3, h * 0.7, w * 0.14, h * 0.22),
        legRadius,
      ),
      darkPaint,
    );
    // Right leg
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.56, h * 0.7, w * 0.14, h * 0.22),
        legRadius,
      ),
      darkPaint,
    );

    // ── Chest panel (decorative) ──────────────────────────────────────────
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.35, h * 0.38, w * 0.3, h * 0.16),
        Radius.circular(w * 0.06),
      ),
      darkPaint,
    );
    // Panel lights
    canvas.drawCircle(Offset(w * 0.43, h * 0.46), w * 0.03, sagePaint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.46), w * 0.03, whitePaint);
    canvas.drawCircle(Offset(w * 0.57, h * 0.46), w * 0.03, sagePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
