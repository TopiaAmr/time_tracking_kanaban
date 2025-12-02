import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/app_header.dart';
import 'package:time_tracking_kanaban/core/widgets/task_history_skeleton.dart';
import 'package:time_tracking_kanaban/di.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_task_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
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
    final cubit = getIt<TaskHistoryCubit>();
    
    // Load history only if not already loaded
    if (cubit.state is! TaskHistoryLoaded) {
      cubit.loadHistory();
    }
    
    return BlocProvider.value(
      value: cubit,
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

              final theme = Theme.of(context);
              final totalTrackedSeconds = state.summaries
                  .fold<int>(0, (sum, s) => sum + s.totalTrackedSeconds);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;

                  final list = ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.summaries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.l10n.historyCompletedTasks,
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${state.summaries.length} tasks',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _formatDuration(totalTrackedSeconds),
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Total time tracked',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withValues(
                                          alpha: 0.6,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final summary = state.summaries[index - 1];
                      return _TaskHistoryItem(
                        summary: summary,
                        isWide: isWide,
                        theme: theme,
                        formatDuration: _formatDuration,
                      );
                    },
                  );

                  if (!isWide) return list;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: list,
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

class _TaskHistoryItem extends StatefulWidget {
  final TaskTimerSummary summary;
  final bool isWide;
  final ThemeData theme;
  final String Function(int seconds) formatDuration;

  const _TaskHistoryItem({
    required this.summary,
    required this.isWide,
    required this.theme,
    required this.formatDuration,
  });

  @override
  State<_TaskHistoryItem> createState() => _TaskHistoryItemState();
}

class _TaskHistoryItemState extends State<_TaskHistoryItem> {
  late final Future<Result<Task>> _taskFuture;

  @override
  void initState() {
    super.initState();
    final getTaskUseCase = getIt<GetTask>();
    _taskFuture = getTaskUseCase(GetTaskParams(widget.summary.taskId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Result<Task>>(
      future: _taskFuture,
      builder: (context, snapshot) {
        String title = 'Task ${widget.summary.taskId}';

        if (snapshot.hasData && snapshot.data is Success<Task>) {
          final task = (snapshot.data as Success<Task>).value;
          title = task.content;
        }

        final theme = widget.theme;
        final summary = widget.summary;

        if (widget.isWide) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: summary.hasActiveTimer
                          ? theme.colorScheme.primary.withValues(alpha: 0.1)
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      summary.hasActiveTimer
                          ? Icons.play_circle_fill
                          : Icons.check_circle,
                      color: summary.hasActiveTimer
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.formatDuration(summary.totalTrackedSeconds),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  if (summary.hasActiveTimer)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Icon(
              summary.hasActiveTimer
                  ? Icons.play_circle_fill
                  : Icons.check_circle,
              color: summary.hasActiveTimer
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            title: Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              widget.formatDuration(summary.totalTrackedSeconds),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            trailing: summary.hasActiveTimer
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.access_time,
                    color: theme.colorScheme.primary,
                  ),
          ),
        );
      },
    );
  }
}

