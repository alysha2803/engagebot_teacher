import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Central ThemeData for the EngageBot Teacher app.
abstract final class AppTheme {
  // ── Light ───────────────────────────────────────────────────────────────

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        surface: AppColors.cardWhite,
        onSurface: AppColors.textPrimary,
      ),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme,
          primary: AppColors.textPrimary,
          secondary: AppColors.textSecondary,
          muted: AppColors.textMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.cardWhite,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderLight),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      switchTheme: _switchTheme(AppColors.primaryGreen, AppColors.textMuted,
          AppColors.borderLight),
      dividerTheme:
          const DividerThemeData(color: AppColors.borderLight),
    );
  }

  // ── Dark ────────────────────────────────────────────────────────────────

  static ThemeData get dark {
    const darkBg = Color(0xFF161A13);
    const darkCard = Color(0xFF1E2419);
    const darkSurface = Color(0xFF252D1E);
    const darkText = Color(0xFFEEF0E8);
    const darkTextSec = Color(0xFF9DAA8E);
    const darkMuted = Color(0xFF6B7A5E);
    const darkBorder = Color(0xFF2E3828);

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryGreen,
        onPrimary: Colors.white,
        surface: darkCard,
        onSurface: darkText,
        surfaceContainerHighest: darkSurface,
      ),
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme,
          primary: darkText,
          secondary: darkTextSec,
          muted: darkMuted),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkCard,
        foregroundColor: darkText,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: darkMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        hintStyle: const TextStyle(color: darkMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: darkText,
          side: const BorderSide(color: darkBorder),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          padding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      switchTheme: _switchTheme(
          AppColors.primaryGreen, darkMuted, darkBorder),
      dividerTheme: const DividerThemeData(color: darkBorder),
      cardColor: darkCard,
      dialogTheme: const DialogThemeData(backgroundColor: darkCard),
      bottomSheetTheme:
          const BottomSheetThemeData(backgroundColor: darkCard),
    );
  }

  // ── Shared helpers ───────────────────────────────────────────────────────

  static TextTheme _textTheme(
    TextTheme base, {
    required Color primary,
    required Color secondary,
    required Color muted,
  }) =>
      base.copyWith(
        headlineMedium: GoogleFonts.inter(
            fontSize: 24, fontWeight: FontWeight.w700, color: primary),
        titleLarge: GoogleFonts.inter(
            fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleMedium: GoogleFonts.inter(
            fontSize: 16, fontWeight: FontWeight.w500, color: primary),
        bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: secondary),
        labelSmall: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w500, color: muted),
      );

  static SwitchThemeData _switchTheme(
    Color active,
    Color inactive,
    Color track,
  ) =>
      SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return inactive;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return active;
          return track;
        }),
      );
}
