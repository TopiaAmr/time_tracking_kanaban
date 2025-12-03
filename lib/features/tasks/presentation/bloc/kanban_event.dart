import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Base class for Kanban board events.
abstract class KanbanEvent extends Equatable {
  const KanbanEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all tasks and group them into Kanban columns.
class LoadKanbanTasks extends KanbanEvent {
  /// Whether to force refresh from API and update local cache.
  final bool forceRefresh;

  const LoadKanbanTasks({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Event to move a task between columns.
class MoveTaskEvent extends KanbanEvent {
  /// The task to move.
  final Task task;

  /// The target project ID.
  final String projectId;

  /// The target section ID (null for tasks without section).
  final String? sectionId;

  const MoveTaskEvent({
    required this.task,
    required this.projectId,
    this.sectionId,
  });

  @override
  List<Object?> get props => [task, projectId, sectionId];
}

/// Event to create a new task.
class CreateTask extends KanbanEvent {
  /// The task to create.
  final Task task;

  const CreateTask(this.task);

  @override
  List<Object?> get props => [task];
}

/// Event to update an existing task.
class UpdateTaskEvent extends KanbanEvent {
  /// The task with updated information.
  final Task task;

  const UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

/// Event to close (complete) a task.
class CloseTaskEvent extends KanbanEvent {
  /// The task to close.
  final Task task;

  const CloseTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

/// Event to delete a task.
class DeleteTaskEvent extends KanbanEvent {
  /// The ID of the task to delete.
  final String taskId;

  const DeleteTaskEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

