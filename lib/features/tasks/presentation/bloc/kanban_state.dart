import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Base class for Kanban board states.
abstract class KanbanState extends Equatable {
  const KanbanState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the Kanban board is first created.
class KanbanInitial extends KanbanState {
  const KanbanInitial();
}

/// State when tasks are being loaded.
class KanbanLoading extends KanbanState {
  const KanbanLoading();
}

/// State when tasks have been successfully loaded and grouped into columns.
class KanbanLoaded extends KanbanState {
  /// Tasks in the "To Do" column.
  final List<Task> toDoTasks;

  /// Tasks in the "In Progress" column.
  final List<Task> inProgressTasks;

  /// Tasks in the "Done" column.
  final List<Task> doneTasks;

  const KanbanLoaded({
    required this.toDoTasks,
    required this.inProgressTasks,
    required this.doneTasks,
  });

  @override
  List<Object?> get props => [toDoTasks, inProgressTasks, doneTasks];
}

/// State when an error occurs.
class KanbanError extends KanbanState {
  /// The failure that occurred.
  final Failure failure;

  const KanbanError(this.failure);

  @override
  List<Object?> get props => [failure];
}
