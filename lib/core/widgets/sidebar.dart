import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/navigation/route_names.dart';
import 'package:time_tracking_kanaban/core/widgets/responsive.dart';

/// Left navigation sidebar with responsive behavior.
///
/// On mobile: Used in drawer
/// On desktop: Fixed sidebar
class Sidebar extends StatelessWidget {
  /// Current route path to highlight active item.
  final String currentPath;

  const Sidebar({super.key, required this.currentPath});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    final theme = Theme.of(context);

    return Container(
      width: isMobile ? null : 240,
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          // Logo section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      'K',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  context.l10n.appTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // _NavItem(
                //   icon: Icons.dashboard_outlined,
                //   activeIcon: Icons.dashboard,
                //   label: context.l10n.navOverview,
                //   route: RouteNames.overview,
                //   currentPath: currentPath,
                // ),
                // _NavItem(
                //   icon: Icons.folder_outlined,
                //   activeIcon: Icons.folder,
                //   label: context.l10n.navProjects,
                //   route: RouteNames.projects,
                //   currentPath: currentPath,
                // ),
                _NavItem(
                  icon: Icons.checklist_outlined,
                  activeIcon: Icons.checklist,
                  label: context.l10n.navTasks,
                  route: RouteNames.tasks,
                  currentPath: currentPath,
                ),
                _NavItem(
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: context.l10n.timerHistory,
                  route: RouteNames.history,
                  currentPath: currentPath,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Settings
          _NavItem(
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: context.l10n.navSettings,
            route: RouteNames.settings,
            currentPath: currentPath,
          ),

          // User profile section
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    'A',
                    style: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Aunnur Sakkhor',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'aunnursakkhor@gmail.com',
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;
  final String currentPath;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
    required this.currentPath,
  });

  bool get isActive => currentPath.startsWith(route);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = this.isActive;

    return InkWell(
      onTap: () {
        context.go(route);
        if (context.isMobile) {
          Navigator.of(context).pop(); // Close drawer on mobile
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
