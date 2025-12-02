import 'package:flutter/material.dart';

/// Supported locales in the application.
class SupportedLocales {
  /// List of all supported locales.
  static const List<Locale> locales = [
    Locale('en', ''), // English
    Locale('tr', ''), // Turkish
    Locale('de', ''), // German
    Locale('fr', ''), // French
  ];

  /// Default locale (English).
  static const Locale defaultLocale = Locale('en', '');

  /// Get locale display name in its native form.
  static String getLocaleDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'tr':
        return 'Türkçe';
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      default:
        return locale.languageCode.toUpperCase();
    }
  }
}

