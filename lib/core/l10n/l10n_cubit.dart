import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_state.dart';
import 'package:time_tracking_kanaban/core/l10n/supported_locales.dart';

/// Cubit for managing application locale.
@injectable
class L10nCubit extends Cubit<L10nState> {
  final SharedPreferences _prefs;
  static const String _localeKey = 'app_locale';

  L10nCubit(this._prefs) : super(L10nState.initial()) {
    _loadLocale();
  }

  /// Load saved locale from preferences.
  Future<void> _loadLocale() async {
    final localeCode = _prefs.getString(_localeKey);
    if (localeCode != null) {
      final locale = Locale(localeCode);
      if (SupportedLocales.locales.contains(locale)) {
        emit(state.copyWith(locale: locale));
      }
    }
  }

  /// Change the application locale.
  Future<void> changeLocale(Locale locale) async {
    if (!SupportedLocales.locales.contains(locale)) {
      return;
    }

    await _prefs.setString(_localeKey, locale.languageCode);
    emit(state.copyWith(locale: locale));
  }

  /// Get current locale.
  Locale get currentLocale => state.locale;
}

