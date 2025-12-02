import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:time_tracking_kanaban/core/navigation/route_names.dart';
import 'package:time_tracking_kanaban/core/screens/overview_screen.dart';
import 'package:time_tracking_kanaban/core/screens/projects_screen.dart';
import 'package:time_tracking_kanaban/core/screens/settings_screen.dart';
import 'package:time_tracking_kanaban/di.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/screens/kanban_board_screen.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/screens/task_history_screen.dart';

/// Application router configuration using go_router.
class AppRouter {
  /// Create the router configuration.
  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: RouteNames.tasks,
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'Page not found',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go(RouteNames.tasks),
                child: const Text('Go to Tasks'),
              ),
            ],
          ),
        ),
      ),
      routes: [
        GoRoute(
          path: RouteNames.root,
          redirect: (context, state) => RouteNames.tasks,
        ),
        GoRoute(
          path: RouteNames.overview,
          pageBuilder: (context, state) => _buildSlideTransition(
            context: context,
            state: state,
            child: const OverviewScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.projects,
          pageBuilder: (context, state) => _buildSlideTransition(
            context: context,
            state: state,
            child: const ProjectsScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.tasks,
          pageBuilder: (context, state) => _buildSlideTransition(
            context: context,
            state: state,
            child: BlocProvider(
              create: (context) => getIt<KanbanBloc>(),
              child: const KanbanBoardScreen(),
            ),
          ),
          routes: [
            GoRoute(
              path: ':id',
              pageBuilder: (context, state) {
                final taskId = state.pathParameters['id']!;
                return _buildFadeTransition(
                  context: context,
                  state: state,
                  child: TaskDetailScreen(taskId: taskId),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.settings,
          pageBuilder: (context, state) => _buildFadeTransition(
            context: context,
            state: state,
            child: const SettingsScreen(),
          ),
        ),
        GoRoute(
          path: RouteNames.history,
          pageBuilder: (context, state) => _buildSlideTransition(
            context: context,
            state: state,
            child: const TaskHistoryScreen(),
          ),
        ),
      ],
    );
  }

  /// Builds a fade transition for modal-like screens.
  static Page _buildFadeTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1024;
    
    if (isLargeScreen) {
      return NoTransitionPage(
        key: state.pageKey,
        child: child,
      );
    }
    
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }

  /// Builds a slide transition for main navigation screens.
  static Page _buildSlideTransition({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1024;
    
    if (isLargeScreen) {
      return NoTransitionPage(
        key: state.pageKey,
        child: child,
      );
    }
    
    return CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.1, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeOutCubic;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
