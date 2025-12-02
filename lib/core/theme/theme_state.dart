import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Theme mode for the application.
enum ThemeModeType {
  light,
  dark,
  system,
}

/// State for theme management.
class ThemeState extends Equatable {
  /// The current theme mode.
  final ThemeModeType themeMode;

  /// Custom primary color (null means use default).
  final Color? customPrimaryColor;

  /// Custom secondary color (null means use default).
  final Color? customSecondaryColor;

  /// Custom accent colors (null means use default).
  final CustomAccentColors? customAccentColors;

  const ThemeState({
    required this.themeMode,
    this.customPrimaryColor,
    this.customSecondaryColor,
    this.customAccentColors,
  });

  /// Initial state with light theme.
  factory ThemeState.initial() {
    return const ThemeState(themeMode: ThemeModeType.light);
  }

  /// Copy with method for immutable updates.
  ThemeState copyWith({
    ThemeModeType? themeMode,
    Color? customPrimaryColor,
    Color? customSecondaryColor,
    CustomAccentColors? customAccentColors,
    bool clearPrimaryColor = false,
    bool clearSecondaryColor = false,
    bool clearAccentColors = false,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      customPrimaryColor: clearPrimaryColor
          ? null
          : (customPrimaryColor ?? this.customPrimaryColor),
      customSecondaryColor: clearSecondaryColor
          ? null
          : (customSecondaryColor ?? this.customSecondaryColor),
      customAccentColors: clearAccentColors
          ? null
          : (customAccentColors ?? this.customAccentColors),
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        customPrimaryColor,
        customSecondaryColor,
        customAccentColors,
      ];
}

/// Custom accent colors for the theme.
class CustomAccentColors extends Equatable {
  final Color? blue;
  final Color? green;
  final Color? orange;
  final Color? purple;
  final Color? red;

  const CustomAccentColors({
    this.blue,
    this.green,
    this.orange,
    this.purple,
    this.red,
  });

  CustomAccentColors copyWith({
    Color? blue,
    Color? green,
    Color? orange,
    Color? purple,
    Color? red,
    bool clearBlue = false,
    bool clearGreen = false,
    bool clearOrange = false,
    bool clearPurple = false,
    bool clearRed = false,
  }) {
    return CustomAccentColors(
      blue: clearBlue ? null : (blue ?? this.blue),
      green: clearGreen ? null : (green ?? this.green),
      orange: clearOrange ? null : (orange ?? this.orange),
      purple: clearPurple ? null : (purple ?? this.purple),
      red: clearRed ? null : (red ?? this.red),
    );
  }

  @override
  List<Object?> get props => [blue, green, orange, purple, red];
}

