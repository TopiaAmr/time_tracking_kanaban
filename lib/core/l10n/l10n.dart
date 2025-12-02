import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/l10n/app_localizations.dart';

/// Extension to easily access localizations from BuildContext.
extension L10nExtension on BuildContext {
  /// Get the AppLocalizations instance for the current locale.
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

