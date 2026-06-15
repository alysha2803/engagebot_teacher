import 'package:flutter/material.dart';

/// AppColors — all static colour constants for the EngageBot Teacher app.
/// Never hardcode colours elsewhere; always reference this file or the
/// BuildContext extension below for adaptive surface colours.

abstract final class AppColors {
  // Primary
  static const primaryGreen = Color(0xFF9CAF88);
  static const primaryGreenDark = Color(0xFF7A8C5E);

  // Backgrounds (light-mode constants — use context extension for adaptive)
  static const backgroundLight = Color(0xFFF5F5F0);
  static const cardWhite = Color(0xFFFFFFFF);
  static const sageLight = Color(0xFFD6DEC8);
  static const sageLighter = Color(0xFFEEF2E6);

  // Text (light-mode constants — use context extension for adaptive)
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B7280);
  static const textMuted = Color(0xFF9CA3AF);

  // Semantic — same in both modes
  static const liveRed = Color(0xFFE53E3E);
  static const successGreen = Color(0xFF48BB78);
  static const warningAmber = Color(0xFFF59E0B);

  // Structural (light-mode constant — use context extension for adaptive)
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

// ─────────────────────────────────────────────────────────────────────────────
// BuildContext extension — adaptive surface colours
// Use these instead of AppColors constants when the colour must respond to
// dark-mode toggling.
// ─────────────────────────────────────────────────────────────────────────────

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  /// The Scaffold background colour.
  Color get colorBg => Theme.of(this).scaffoldBackgroundColor;

  /// Card / sheet surface colour.
  Color get colorCard => Theme.of(this).colorScheme.surface;

  /// Primary text on a card.
  Color get colorOnCard => Theme.of(this).colorScheme.onSurface;

  /// Secondary / supporting text.
  Color get colorSubtle =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.6);

  /// Muted labels and timestamps.
  Color get colorMuted =>
      Theme.of(this).colorScheme.onSurface.withValues(alpha: 0.38);

  /// Divider / outline colour.
  Color get colorBorder => Theme.of(this).dividerColor;

  /// Icon background (rounded square behind feature icons).
  Color get colorIconBg =>
      isDark ? const Color(0xFF1E2B1A) : AppColors.sageLighter;

  /// Avatar circle background.
  Color get colorAvatarBg =>
      isDark ? const Color(0xFF253020) : AppColors.sageLight;

  /// Subtle toggle/chip background (unselected state).
  Color get colorChipBg =>
      isDark ? const Color(0xFF1A1E17) : const Color(0xFFF0F0EC);

  /// Input field fill colour.
  Color get colorInputFill =>
      isDark ? const Color(0xFF252D1E) : const Color(0xFFF3F4F6);
}
