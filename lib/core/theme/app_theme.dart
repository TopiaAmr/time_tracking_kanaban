import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/theme/app_colors.dart';
import 'package:time_tracking_kanaban/core/theme/theme_state.dart';

/// Application theme configuration.
class AppTheme {
  AppTheme._();

  /// Light theme configuration.
  static ThemeData lightTheme([ThemeState? themeState]) {
    final primaryColor = themeState?.customPrimaryColor ?? AppColors.accentBlue;
    final secondaryColor =
        themeState?.customSecondaryColor ?? AppColors.accentPurple;
    final accentColors = themeState?.customAccentColors;
    final errorColor = accentColors?.red ?? AppColors.accentRed;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: AppColors.lightSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.lightTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14,
        ),
        bodySmall: TextStyle(color: AppColors.lightTextSecondary, fontSize: 12),
      ),
      iconTheme: const IconThemeData(color: AppColors.lightTextSecondary),
      dividerColor: AppColors.lightBorder,
    );
  }

  /// Dark theme configuration.
  static ThemeData darkTheme([ThemeState? themeState]) {
    final primaryColor = themeState?.customPrimaryColor ?? AppColors.accentBlue;
    final secondaryColor =
        themeState?.customSecondaryColor ?? AppColors.accentPurple;
    final accentColors = themeState?.customAccentColors;
    final errorColor = accentColors?.red ?? AppColors.accentRed;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        surface: AppColors.darkSurface,
        error: errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.darkTextPrimary,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.darkTextSecondary, fontSize: 12),
      ),
      iconTheme: const IconThemeData(color: AppColors.darkTextSecondary),
      dividerColor: AppColors.darkBorder,
    );
  }
}
