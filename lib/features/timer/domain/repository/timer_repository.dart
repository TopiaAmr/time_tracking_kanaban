import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_history_detail.dart';

/// Abstraction over timer/time tracking operations.
///
/// Infrastructure implementations are responsible for:
/// - Ensuring only a single active timer exists at any time.
/// - Persisting timer state (e.g. using Drift) so it survives app restarts.
/// - Coordinating with tasks data if needed.
abstract class TimerRepository {
  /// Starts a new timer for the given [taskId].
  ///
  /// Implementations should stop any currently active timer before
  /// starting a new one.
  Future<Result<TimeLog>> startTimer(String taskId);

  /// Pauses the active timer (if any) and returns the updated [TimeLog].
  ///
  /// If no timer is active, this should return a failure.
  Future<Result<TimeLog>> pauseTimer();

  /// Resumes a timer for the given [taskId].
  ///
  /// Implementations may either:
  /// - create a new [TimeLog] entry, or
  /// - reopen a previously paused one,
  /// depending on the chosen persistence model.
  Future<Result<TimeLog>> resumeTimer(String taskId);

  /// Stops the active timer (if any) and returns the final [TimeLog].
  Future<Result<TimeLog>> stopTimer();

  /// Returns the currently active timer, if any.
  Future<Result<TimeLog?>> getActiveTimer();

  /// Returns all time logs associated with the given [taskId].
  Future<Result<List<TimeLog>>> getTimeLogsForTask(String taskId);

  /// Returns an aggregated summary of tracked time for the given [taskId].
  Future<Result<TaskTimerSummary>> getTaskTimerSummary(String taskId);

  /// Returns summaries for all completed tasks, intended for the
  /// "Task History" view.
  Future<Result<List<TaskTimerSummary>>> getCompletedTasksHistory();

  /// Returns detailed history for all completed tasks, including time logs.
  /// Intended for the "Task History" view with expanded details.
  Future<Result<List<TaskHistoryDetail>>> getCompletedTasksHistoryDetailed();
}
