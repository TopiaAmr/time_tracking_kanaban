import 'package:flutter/material.dart';

/// Typography system for the application.
class AppTextStyles {
  AppTextStyles._();

  /// Heading 1 style - for main page titles
  static TextStyle heading1(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 28,
        ) ??
        const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
        );
  }

  /// Heading 2 style - for section titles
  static TextStyle heading2(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 22,
        ) ??
        const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
        );
  }

  /// Heading 3 style - for subsection titles
  static TextStyle heading3(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ) ??
        const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        );
  }

  /// Body text style
  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontSize: 16,
        ) ??
        const TextStyle(fontSize: 16);
  }

  /// Body small style
  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 14,
        ) ??
        const TextStyle(fontSize: 14);
  }

  /// Caption style
  static TextStyle caption(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
        ) ??
        const TextStyle(fontSize: 12);
  }

  /// Button text style
  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ) ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        );
  }
}

