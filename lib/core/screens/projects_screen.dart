import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';

/// Projects screen.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentPath: '/projects',
      header: AppHeader(
        title: context.l10n.projectsTitle,
      ),
      body: Center(
        child: Text(
          context.l10n.projectsTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}

