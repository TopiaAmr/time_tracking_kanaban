import 'package:flutter/services.dart';

/// Service for providing haptic feedback throughout the application.
class HapticService {
  HapticService._();

  /// Provide light haptic feedback for subtle interactions.
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Provide medium haptic feedback for button presses.
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Provide heavy haptic feedback for important actions.
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Provide selection click feedback for toggle switches.
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Provide vibrate feedback (legacy).
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}

