import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracking_kanaban/core/theme/theme_state.dart';

/// Cubit for managing application theme.
@injectable
class ThemeCubit extends Cubit<ThemeState> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'app_theme_mode';
  static const String _primaryColorKey = 'app_primary_color';
  static const String _secondaryColorKey = 'app_secondary_color';
  static const String _accentBlueKey = 'app_accent_blue';
  static const String _accentGreenKey = 'app_accent_green';
  static const String _accentOrangeKey = 'app_accent_orange';
  static const String _accentPurpleKey = 'app_accent_purple';
  static const String _accentRedKey = 'app_accent_red';

  ThemeCubit(this._prefs) : super(ThemeState.initial()) {
    _loadTheme();
  }

  /// Load saved theme from preferences.
  Future<void> _loadTheme() async {
    final themeModeString = _prefs.getString(_themeKey);
    ThemeModeType? themeMode;
    if (themeModeString != null) {
      themeMode = ThemeModeType.values.firstWhere(
        (mode) => mode.name == themeModeString,
        orElse: () => ThemeModeType.light,
      );
    }

    // Load custom colors
    final primaryColorValue = _prefs.getInt(_primaryColorKey);
    final secondaryColorValue = _prefs.getInt(_secondaryColorKey);
    final accentBlueValue = _prefs.getInt(_accentBlueKey);
    final accentGreenValue = _prefs.getInt(_accentGreenKey);
    final accentOrangeValue = _prefs.getInt(_accentOrangeKey);
    final accentPurpleValue = _prefs.getInt(_accentPurpleKey);
    final accentRedValue = _prefs.getInt(_accentRedKey);

    final customPrimaryColor = primaryColorValue != null
        ? Color(primaryColorValue)
        : null;
    final customSecondaryColor = secondaryColorValue != null
        ? Color(secondaryColorValue)
        : null;

    CustomAccentColors? customAccentColors;
    if (accentBlueValue != null ||
        accentGreenValue != null ||
        accentOrangeValue != null ||
        accentPurpleValue != null ||
        accentRedValue != null) {
      customAccentColors = CustomAccentColors(
        blue: accentBlueValue != null ? Color(accentBlueValue) : null,
        green: accentGreenValue != null ? Color(accentGreenValue) : null,
        orange: accentOrangeValue != null ? Color(accentOrangeValue) : null,
        purple: accentPurpleValue != null ? Color(accentPurpleValue) : null,
        red: accentRedValue != null ? Color(accentRedValue) : null,
      );
    }

    emit(
      ThemeState(
        themeMode: themeMode ?? ThemeModeType.light,
        customPrimaryColor: customPrimaryColor,
        customSecondaryColor: customSecondaryColor,
        customAccentColors: customAccentColors,
      ),
    );
  }

  /// Change the application theme mode.
  Future<void> changeThemeMode(ThemeModeType themeMode) async {
    await _prefs.setString(_themeKey, themeMode.name);
    emit(state.copyWith(themeMode: themeMode));
  }

  /// Update the primary color.
  Future<void> updatePrimaryColor(Color? color) async {
    if (color == null) {
      await _prefs.remove(_primaryColorKey);
      emit(state.copyWith(clearPrimaryColor: true));
    } else {
      await _prefs.setInt(_primaryColorKey, color.toARGB32());
      emit(state.copyWith(customPrimaryColor: color));
    }
  }

  /// Update the secondary color.
  Future<void> updateSecondaryColor(Color? color) async {
    if (color == null) {
      await _prefs.remove(_secondaryColorKey);
      emit(state.copyWith(clearSecondaryColor: true));
    } else {
      await _prefs.setInt(_secondaryColorKey, color.toARGB32());
      emit(state.copyWith(customSecondaryColor: color));
    }
  }

  /// Update an accent color.
  Future<void> updateAccentColor({
    Color? blue,
    Color? green,
    Color? orange,
    Color? purple,
    Color? red,
  }) async {
    final currentAccents =
        state.customAccentColors ?? const CustomAccentColors();
    final updatedAccents = currentAccents.copyWith(
      blue: blue,
      green: green,
      orange: orange,
      purple: purple,
      red: red,
      clearBlue: blue == null && currentAccents.blue != null,
      clearGreen: green == null && currentAccents.green != null,
      clearOrange: orange == null && currentAccents.orange != null,
      clearPurple: purple == null && currentAccents.purple != null,
      clearRed: red == null && currentAccents.red != null,
    );

    // Save to preferences
    if (blue != null) {
      await _prefs.setInt(_accentBlueKey, blue.toARGB32());
    } else if (updatedAccents.blue == null) {
      await _prefs.remove(_accentBlueKey);
    }

    if (green != null) {
      await _prefs.setInt(_accentGreenKey, green.toARGB32());
    } else if (updatedAccents.green == null) {
      await _prefs.remove(_accentGreenKey);
    }

    if (orange != null) {
      await _prefs.setInt(_accentOrangeKey, orange.toARGB32());
    } else if (updatedAccents.orange == null) {
      await _prefs.remove(_accentOrangeKey);
    }

    if (purple != null) {
      await _prefs.setInt(_accentPurpleKey, purple.toARGB32());
    } else if (updatedAccents.purple == null) {
      await _prefs.remove(_accentPurpleKey);
    }

    if (red != null) {
      await _prefs.setInt(_accentRedKey, red.toARGB32());
    } else if (updatedAccents.red == null) {
      await _prefs.remove(_accentRedKey);
    }

    emit(state.copyWith(customAccentColors: updatedAccents));
  }

  /// Reset all custom colors to defaults.
  Future<void> resetCustomColors() async {
    await _prefs.remove(_primaryColorKey);
    await _prefs.remove(_secondaryColorKey);
    await _prefs.remove(_accentBlueKey);
    await _prefs.remove(_accentGreenKey);
    await _prefs.remove(_accentOrangeKey);
    await _prefs.remove(_accentPurpleKey);
    await _prefs.remove(_accentRedKey);
    emit(
      state.copyWith(
        clearPrimaryColor: true,
        clearSecondaryColor: true,
        clearAccentColors: true,
      ),
    );
  }

  /// Toggle between light and dark theme.
  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeModeType.light
        ? ThemeModeType.dark
        : ThemeModeType.light;
    await changeThemeMode(newMode);
  }

  /// Get Flutter ThemeMode from ThemeModeType.
  ThemeMode get flutterThemeMode {
    switch (state.themeMode) {
      case ThemeModeType.light:
        return ThemeMode.light;
      case ThemeModeType.dark:
        return ThemeMode.dark;
      case ThemeModeType.system:
        return ThemeMode.system;
    }
  }
}
