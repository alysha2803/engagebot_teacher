import 'package:flutter/material.dart';

/// AppColors — all colour constants for the EngageBot Teacher app.
/// Never hardcode colours elsewhere; always reference this file.

abstract final class AppColors {
  // Primary
  static const primaryGreen = Color(0xFF7A8C5E);
  static const primaryGreenDark = Color(0xFF5C6B43);

  // Backgrounds
  static const backgroundLight = Color(0xFFF5F5F0);
  static const cardWhite = Color(0xFFFFFFFF);
  static const sageLight = Color(0xFFD6DEC8);
  static const sageLighter = Color(0xFFEEF2E6);

  // Text
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Semantic
  static const liveRed = Color(0xFFE53E3E);
  static const successGreen = Color(0xFF48BB78);
  static const warningAmber = Color(0xFFF59E0B);

  // Structural
  static const borderLight = Color(0xFFE5E7EB);

  // Card shadow helper
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
}
