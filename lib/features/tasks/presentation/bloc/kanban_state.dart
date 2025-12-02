import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
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
  /// Map of section ID to list of tasks in that section.
  final Map<String, List<Task>> tasksBySection;

  /// Tasks without a section (sectionId is empty or invalid).
  final List<Task> tasksWithoutSection;

  /// All sections available in the project, sorted by sectionOrder.
  final List<Section> sections;

  const KanbanLoaded({
    required this.tasksBySection,
    required this.tasksWithoutSection,
    required this.sections,
  });

  @override
  List<Object?> get props => [tasksBySection, tasksWithoutSection, sections];
}

/// State when an error occurs.
class KanbanError extends KanbanState {
  /// The failure that occurred.
  final Failure failure;

  const KanbanError(this.failure);

  @override
  List<Object?> get props => [failure];
}
