import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_history_detail.dart';

/// Base class for task history states.
abstract class TaskHistoryState extends Equatable {
  const TaskHistoryState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the task history view is first created.
class TaskHistoryInitial extends TaskHistoryState {
  const TaskHistoryInitial();
}

/// State when task history is being loaded.
class TaskHistoryLoading extends TaskHistoryState {
  const TaskHistoryLoading();
}

/// State when task history has been successfully loaded.
class TaskHistoryLoaded extends TaskHistoryState {
  /// List of completed tasks with their timer summaries.
  final List<TaskTimerSummary> summaries;

  const TaskHistoryLoaded(this.summaries);

  @override
  List<Object?> get props => [summaries];
}

/// State when detailed task history has been successfully loaded.
class TaskHistoryDetailedLoaded extends TaskHistoryState {
  /// List of completed tasks with their detailed timer history.
  final List<TaskHistoryDetail> details;

  const TaskHistoryDetailedLoaded(this.details);

  @override
  List<Object?> get props => [details];
}

/// State when an error occurs while loading task history.
class TaskHistoryError extends TaskHistoryState {
  /// The failure that occurred.
  final Failure failure;

  const TaskHistoryError(this.failure);

  @override
  List<Object?> get props => [failure];
}

