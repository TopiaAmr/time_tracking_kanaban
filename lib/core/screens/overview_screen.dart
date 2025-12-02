import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';

/// Overview/Dashboard screen.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class OverviewScreen extends StatelessWidget {
  const OverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentPath: '/overview',
      header: AppHeader(
        title: context.l10n.overviewTitle,
      ),
      body: Center(
        child: Text(
          context.l10n.overviewTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

