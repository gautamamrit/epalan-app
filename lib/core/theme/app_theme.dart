import 'package:flutter/material.dart';
import 'app_colors.dart';

const _fontFamily = 'Inter';
const _displayFont = 'Fraunces';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        secondary: AppColors.primaryLight,
        surface: AppColors.surface,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.background,
      textTheme: _textTheme,
      appBarTheme: _appBarTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      cardTheme: _cardTheme,
      listTileTheme: _listTileTheme,
      iconTheme: const IconThemeData(
        size: 22,
        color: AppColors.textPrimary,
      ),
      elevatedButtonTheme: _elevatedButtonTheme,
      outlinedButtonTheme: _outlinedButtonTheme,
      textButtonTheme: _textButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        titleTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        contentTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, color: AppColors.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        contentTextStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 14),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.divider, thickness: 1),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
    );
  }

  // ── TYPE SCALE (from brand system tokens) ──
  //
  //  Style           Size  Weight  Font      Tracking   Usage
  //  ─────────────────────────────────────────────────────────
  //  Display XL      56    600     Fraunces  -0.02em    Hero / onboarding
  //  Display         40    600     Fraunces  -0.02em    Section starters
  //  Title L         28    700     Inter     -0.01em    Screen titles
  //  Title           22    700     Inter     -0.01em    Card headers
  //  Body L          17    500     Inter     0          Primary paragraph
  //  Body            15    500     Inter     0          Default UI text
  //  Caption         13    600     Inter     0.01em     Meta / labels
  //  Overline        11    700     Inter     0.14em     All-caps tags
  //
  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: TextStyle(fontFamily: _displayFont, fontSize: 56, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.02 * 56),
      displayMedium: TextStyle(fontFamily: _displayFont, fontSize: 40, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.02 * 40),
      displaySmall: TextStyle(fontFamily: _displayFont, fontSize: 32, fontWeight: FontWeight.w600, color: AppColors.textPrimary, letterSpacing: -0.02 * 32),
      headlineLarge: TextStyle(fontFamily: _fontFamily, fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.01 * 28),
      headlineMedium: TextStyle(fontFamily: _fontFamily, fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: -0.01 * 22),
      headlineSmall: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      titleLarge: TextStyle(fontFamily: _fontFamily, fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      titleMedium: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      titleSmall: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary, letterSpacing: 0.01 * 13),
      bodyLarge: TextStyle(fontFamily: _fontFamily, fontSize: 17, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
      bodySmall: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
      labelLarge: TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      labelMedium: TextStyle(fontFamily: _fontFamily, fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
      labelSmall: TextStyle(fontFamily: _fontFamily, fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textTertiary, letterSpacing: 0.14 * 11),
    );
  }

  static AppBarTheme get _appBarTheme {
    return const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: AppColors.textPrimary, size: 24),
      titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  static BottomNavigationBarThemeData get _bottomNavTheme {
    return const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.inactiveTab,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.w600),
      unselectedLabelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12, fontWeight: FontWeight.normal),
    );
  }

  static ListTileThemeData get _listTileTheme {
    return const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      subtitleTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14, fontWeight: FontWeight.normal, color: AppColors.textSecondary),
      leadingAndTrailingTextStyle: TextStyle(fontFamily: _fontFamily, fontSize: 14, color: AppColors.textSecondary),
    );
  }

  static CardThemeData get _cardTheme {
    return CardThemeData(
      color: AppColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        iconSize: 20,
      ),
    );
  }

  static OutlinedButtonThemeData get _outlinedButtonTheme {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
        iconSize: 20,
      ),
    );
  }

  static TextButtonThemeData get _textButtonTheme {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme get _inputDecorationTheme {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.error)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.error, width: 2)),
      hintStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, color: AppColors.textTertiary),
      labelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, color: AppColors.textSecondary),
    );
  }
}
