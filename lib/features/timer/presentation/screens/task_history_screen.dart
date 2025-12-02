import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';
import 'package:time_tracking_kanaban/core/widgets/task_history_skeleton.dart';
import 'package:time_tracking_kanaban/di.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/cubit/task_history_cubit.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/cubit/task_history_state.dart';

/// Task history screen displaying completed tasks with time summaries.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class TaskHistoryScreen extends StatelessWidget {
  const TaskHistoryScreen({super.key});

  /// Format seconds into readable duration string.
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TaskHistoryCubit>()..loadHistory(),
      child: AppScaffold(
        currentPath: '/history',
        header: AppHeader(
          title: context.l10n.timerHistory,
        ),
        body: BlocBuilder<TaskHistoryCubit, TaskHistoryState>(
          builder: (context, state) {
            if (state is TaskHistoryLoading) {
              return const TaskHistorySkeleton();
            }

            if (state is TaskHistoryError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.errorUnknown,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TaskHistoryCubit>().loadHistory();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is TaskHistoryLoaded) {
              if (state.summaries.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 64,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.l10n.historyCompletedTasks,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No completed tasks yet',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.summaries.length,
                itemBuilder: (context, index) {
                  final summary = state.summaries[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        'Task ${summary.taskId}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      subtitle: Text(
                        _formatDuration(summary.totalTrackedSeconds),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      trailing: Icon(
                        Icons.access_time,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

