import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/core/widgets/app_scaffold.dart';
import 'package:time_tracking_kanaban/core/widgets/task_detail_skeleton.dart';
import 'package:time_tracking_kanaban/di.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:go_router/go_router.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_project_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_event.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/cubit/comments_cubit.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_task_time_logs_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_assignees_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_comments_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_dates_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_description_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_header_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_metadata_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_timer_history_section.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/widgets/task_detail/task_timer_section.dart';

/// Task detail screen displaying task information, comments, and timer.
///
/// Responsive: Adapts layout for mobile/tablet/desktop
class TaskDetailScreen extends StatefulWidget {
  /// Task ID from route parameters.
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  Task? _task;
  Project? _project;
  bool _isLoading = true;
  String? _error;
  final _commentController = TextEditingController();
  List<TimeLog> _timeLogs = [];
  bool _isLoadingTimeLogs = false;

  @override
  void initState() {
    super.initState();
    _loadTask();
    _loadTimeLogs();
    // Comments will be loaded by CommentsCubit provider
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final getTaskUseCase = getIt<GetTask>();
    final result = await getTaskUseCase(GetTaskParams(widget.taskId));

    if (result is Error<Task>) {
      setState(() {
        _error = 'Failed to load task';
        _isLoading = false;
      });
    } else {
      final task = (result as Success<Task>).value;
      setState(() {
        _task = task;
      });

      // Load project information
      if (task.projectId.isNotEmpty) {
        await _loadProject(task.projectId);
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProject(String projectId) async {
    final getProjectUseCase = getIt<GetProject>();
    final result = await getProjectUseCase(GetProjectParams(projectId));

    if (result is Success<Project>) {
      setState(() {
        _project = result.value;
      });
    }
  }

  Future<void> _loadTimeLogs() async {
    setState(() {
      _isLoadingTimeLogs = true;
    });

    final getTaskTimeLogsUseCase = getIt<GetTaskTimeLogsUseCase>();
    final result = await getTaskTimeLogsUseCase(GetTaskTimeLogsParams(widget.taskId));

    if (result is Success<List<TimeLog>>) {
      setState(() {
        _timeLogs = result.value;
        _isLoadingTimeLogs = false;
      });
    } else {
      setState(() {
        _isLoadingTimeLogs = false;
      });
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${secs}s';
    } else if (minutes > 0) {
      return '${minutes}m ${secs}s';
    }
    return '${secs}s';
  }

  int _calculateTotalSeconds() {
    final now = DateTime.now();
    int total = 0;
    for (final log in _timeLogs) {
      total += log.durationSeconds(log.endTime ?? now);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              getIt<CommentsCubit>()..loadComments(widget.taskId),
        ),
      ],
      child: AppScaffold(
        currentPath: '/tasks',
        body: _isLoading
            ? const TaskDetailSkeleton()
            : _error != null
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!),
                    ElevatedButton(
                      onPressed: _loadTask,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : _task == null
            ? const Center(child: Text('Task not found'))
            : _buildTaskDetail(context),
      ),
    );
  }

  Widget _buildTaskDetail(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isLargeScreen = width > 900;

    if (isLargeScreen) {
      return _buildLargeScreenLayout(context);
    }

    return _buildMobileLayout(context);
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskHeaderSection(
            task: _task!,
            onEdit: () => _showEditDialog(context),
            onDelete: () => _showDeleteDialog(context),
          ),
          const SizedBox(height: 24),
          TaskTimerSection(
            task: _task!,
            totalSeconds: _calculateTotalSeconds(),
            formatDuration: _formatDuration,
          ),
          const SizedBox(height: 24),
          TaskMetadataSection(
            task: _task!,
            project: _project,
          ),
          const SizedBox(height: 24),
          TaskTimerHistorySection(
            timeLogs: _timeLogs,
            isLoading: _isLoadingTimeLogs,
            formatDuration: _formatDuration,
          ),
          const SizedBox(height: 24),
          TaskDescriptionSection(task: _task!),
          const SizedBox(height: 24),
          TaskDatesSection(task: _task!),
          const SizedBox(height: 24),
          TaskAssigneesSection(task: _task!),
          const SizedBox(height: 24),
          TaskCommentsSection(
            taskId: widget.taskId,
            commentController: _commentController,
          ),
        ],
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Main Content (Left Column)
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskHeaderSection(
                  task: _task!,
                  onEdit: () => _showEditDialog(context),
                  onDelete: () => _showDeleteDialog(context),
                ),
                const SizedBox(height: 32),
                TaskDescriptionSection(task: _task!),
                const SizedBox(height: 32),
                TaskCommentsSection(
                  taskId: widget.taskId,
                  commentController: _commentController,
                ),
              ],
            ),
          ),
        ),
        // Sidebar (Right Column)
        Container(
          width: 1,
          color: Theme.of(context).dividerColor,
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TaskTimerSection(
                    task: _task!,
                    totalSeconds: _calculateTotalSeconds(),
                    formatDuration: _formatDuration,
                  ),
                  const SizedBox(height: 24),
                  TaskMetadataSection(
                    task: _task!,
                    project: _project,
                  ),
                  const SizedBox(height: 24),
                  TaskDatesSection(task: _task!),
                  const SizedBox(height: 24),
                  TaskAssigneesSection(task: _task!),
                  const SizedBox(height: 24),
                  TaskTimerHistorySection(
                    timeLogs: _timeLogs,
                    isLoading: _isLoadingTimeLogs,
                    formatDuration: _formatDuration,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    if (_task == null) return;

    final titleController = TextEditingController(text: _task!.content);
    final descriptionController = TextEditingController(
      text: _task!.description,
    );
    final priorityController = TextEditingController(
      text: _task!.priority.toString(),
    );
    DateTime? selectedDueDate = _task!.due;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(context.l10n.taskEdit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: context.l10n.taskTitle,
                    border: const OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(
                    labelText: context.l10n.taskDescription,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priorityController,
                        decoration: InputDecoration(
                          labelText: context.l10n.taskPriority,
                          border: const OutlineInputBorder(),
                          helperText: '1-4 (4 is highest)',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDueDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setState(() => selectedDueDate = picked);
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: context.l10n.taskDueDate,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            selectedDueDate != null
                                ? DateFormat(
                                    'MMM d, yyyy',
                                  ).format(selectedDueDate!)
                                : context.l10n.taskNoDueDate,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.taskCancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!mounted) return;
                final navigator = Navigator.of(context);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                final theme = Theme.of(context);
                final l10n = context.l10n;

                final newPriority =
                    int.tryParse(priorityController.text) ?? _task!.priority;
                final updatedTask = Task(
                  userId: _task!.userId,
                  id: _task!.id,
                  projectId: _task!.projectId,
                  sectionId: _task!.sectionId,
                  parentId: _task!.parentId,
                  addedByUid: _task!.addedByUid,
                  assignedByUid: _task!.assignedByUid,
                  responsibleUid: _task!.responsibleUid,
                  labels: _task!.labels,
                  deadline: _task!.deadline,
                  duration: _task!.duration,
                  checked: _task!.checked,
                  isDeleted: _task!.isDeleted,
                  addedAt: _task!.addedAt,
                  completedAt: _task!.completedAt,
                  completedByUid: _task!.completedByUid,
                  updatedAt: DateTime.now(),
                  due: selectedDueDate,
                  priority: newPriority.clamp(1, 4),
                  childOrder: _task!.childOrder,
                  content: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  noteCount: _task!.noteCount,
                  dayOrder: _task!.dayOrder,
                  isCollapsed: _task!.isCollapsed,
                );

                navigator.pop();

                final updateTaskUseCase = getIt<UpdateTaskUseCase>();
                final result = await updateTaskUseCase(
                  UpdateTaskParams(updatedTask),
                );

                if (!mounted) return;

                if (result is Error<Task>) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text(l10n.errorUnknown),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                } else {
                  // Notify KanbanBloc if available (it's registered as factory, so we can get it)
                  try {
                    final kanbanBloc = getIt<KanbanBloc>();
                    kanbanBloc.add(
                      UpdateTaskEvent((result as Success<Task>).value),
                    );
                  } catch (e) {
                    // KanbanBloc might not be available - that's okay
                  }

                  // Reload task
                  await _loadTask();
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      SnackBar(content: Text(l10n.taskUpdated)),
                    );
                  }
                }
              },
              child: Text(context.l10n.taskSave),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.confirmDelete),
        content: Text(context.l10n.confirmDeleteTask),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.no),
          ),
          TextButton(
            onPressed: () async {
              if (!mounted) return;
              final navigator = Navigator.of(context);
              final router = GoRouter.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final theme = Theme.of(context);
              final l10n = context.l10n;

              navigator.pop();

              final deleteTaskUseCase = getIt<DeleteTaskUseCase>();
              final result = await deleteTaskUseCase(
                DeleteTaskParams(widget.taskId),
              );

              if (!mounted) return;

              if (result is Error<void>) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(l10n.errorUnknown),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              } else {
                // Notify KanbanBloc if available
                try {
                  final kanbanBloc = getIt<KanbanBloc>();
                  kanbanBloc.add(DeleteTaskEvent(widget.taskId));
                } catch (e) {
                  // KanbanBloc might not be available
                }

                // Navigate back to tasks list
                router.go('/tasks');
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(content: Text(l10n.taskDeleted)),
                  );
                }
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.yes),
          ),
        ],
      ),
    );
  }
}
