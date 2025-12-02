import 'package:flutter/material.dart';

/// Responsive breakpoints for the application.
class ResponsiveBreakpoints {
  ResponsiveBreakpoints._();

  /// Mobile breakpoint (< 600px)
  static const double mobile = 600;

  /// Tablet breakpoint (600px - 1200px)
  static const double tablet = 1200;

  /// Desktop breakpoint (> 1200px)
  static const double desktop = 1200;
}

/// Extension on BuildContext for responsive utilities.
extension ResponsiveExtension on BuildContext {
  /// Check if current screen is mobile.
  bool get isMobile => MediaQuery.of(this).size.width < ResponsiveBreakpoints.mobile;

  /// Check if current screen is tablet.
  bool get isTablet =>
      MediaQuery.of(this).size.width >= ResponsiveBreakpoints.mobile &&
      MediaQuery.of(this).size.width < ResponsiveBreakpoints.tablet;

  /// Check if current screen is desktop.
  bool get isDesktop => MediaQuery.of(this).size.width >= ResponsiveBreakpoints.desktop;

  /// Get screen width.
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height.
  double get screenHeight => MediaQuery.of(this).size.height;
}

/// Responsive widget builder that provides different layouts based on screen size.
class ResponsiveBuilder extends StatelessWidget {
  /// Widget to show on mobile.
  final Widget? mobile;

  /// Widget to show on tablet.
  final Widget? tablet;

  /// Widget to show on desktop.
  final Widget? desktop;

  /// Default widget if no specific widget is provided for a breakpoint.
  final Widget? fallback;

  const ResponsiveBuilder({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) {
      return desktop!;
    } else if (context.isTablet && tablet != null) {
      return tablet!;
    } else if (context.isMobile && mobile != null) {
      return mobile!;
    } else if (fallback != null) {
      return fallback!;
    } else {
      return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }
  }
}

