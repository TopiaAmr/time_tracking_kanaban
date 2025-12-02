import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/data/datasources/timer_local_datasource.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Implementation of [TimerRepository] using local storage.
///
/// This implementation ensures only one active timer exists at any time
/// and persists all timer state to the local database.
@Injectable(as: TimerRepository)
class TimerRepositoryImpl implements TimerRepository {
  final TimerLocalDataSource localDataSource;

  TimerRepositoryImpl(this.localDataSource);

  @override
  Future<Result<TimeLog>> startTimer(String taskId) async {
    try {
      // Stop any currently active timer
      final activeResult = await localDataSource.getActiveTimeLog();
      if (activeResult is Success<TimeLog?> && activeResult.value != null) {
        final activeLog = activeResult.value!;
        final stoppedLog = TimeLog(
          id: activeLog.id,
          taskId: activeLog.taskId,
          startTime: activeLog.startTime,
          endTime: DateTime.now(),
        );
        await localDataSource.updateTimeLog(stoppedLog);
      }

      // Start new timer
      final now = DateTime.now();
      final timeLog = TimeLog(
        id: 'timer_${now.millisecondsSinceEpoch}',
        taskId: taskId,
        startTime: now,
        endTime: null,
      );

      final result = await localDataSource.insertTimeLog(timeLog);
      if (result is Error) {
        return result;
      }
      return Success(timeLog);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  @override
  Future<Result<TimeLog>> pauseTimer() async {
    try {
      final activeResult = await localDataSource.getActiveTimeLog();
      if (activeResult is Error<TimeLog?>) {
        return Error<TimeLog>(activeResult.failure);
      }

      final activeLog = (activeResult as Success<TimeLog?>).value;
      if (activeLog == null) {
        return Error<TimeLog>(CacheFailure(['No active timer']));
      }

      final pausedLog = TimeLog(
        id: activeLog.id,
        taskId: activeLog.taskId,
        startTime: activeLog.startTime,
        endTime: DateTime.now(),
      );

      final result = await localDataSource.updateTimeLog(pausedLog);
      if (result is Error) {
        return result;
      }
      return Success(pausedLog);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  @override
  Future<Result<TimeLog>> resumeTimer(String taskId) async {
    try {
      // Check if there's already an active timer
      final activeResult = await localDataSource.getActiveTimeLog();
      if (activeResult is Success<TimeLog?> && activeResult.value != null) {
        // If there's an active timer for a different task, stop it first
        final activeLog = activeResult.value!;
        if (activeLog.taskId != taskId) {
          final stoppedLog = TimeLog(
            id: activeLog.id,
            taskId: activeLog.taskId,
            startTime: activeLog.startTime,
            endTime: DateTime.now(),
          );
          await localDataSource.updateTimeLog(stoppedLog);
        } else {
          // Timer already active for this task
          return Success(activeLog);
        }
      }

      // Start new timer (resume creates a new log entry)
      final now = DateTime.now();
      final timeLog = TimeLog(
        id: 'timer_${now.millisecondsSinceEpoch}',
        taskId: taskId,
        startTime: now,
        endTime: null,
      );

      final result = await localDataSource.insertTimeLog(timeLog);
      if (result is Error) {
        return result;
      }
      return Success(timeLog);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  @override
  Future<Result<TimeLog>> stopTimer() async {
    try {
      final activeResult = await localDataSource.getActiveTimeLog();
      if (activeResult is Error<TimeLog?>) {
        return Error<TimeLog>(activeResult.failure);
      }

      final activeLog = (activeResult as Success<TimeLog?>).value;
      if (activeLog == null) {
        return Error<TimeLog>(CacheFailure(['No active timer']));
      }

      final stoppedLog = TimeLog(
        id: activeLog.id,
        taskId: activeLog.taskId,
        startTime: activeLog.startTime,
        endTime: DateTime.now(),
      );

      final result = await localDataSource.updateTimeLog(stoppedLog);
      if (result is Error) {
        return result;
      }
      return Success(stoppedLog);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  @override
  Future<Result<TimeLog?>> getActiveTimer() async {
    return await localDataSource.getActiveTimeLog();
  }

  @override
  Future<Result<List<TimeLog>>> getTimeLogsForTask(String taskId) async {
    return await localDataSource.getTimeLogsForTask(taskId);
  }

  @override
  Future<Result<TaskTimerSummary>> getTaskTimerSummary(String taskId) async {
    try {
      final logsResult = await localDataSource.getTimeLogsForTask(taskId);
      if (logsResult is Error<List<TimeLog>>) {
        return Error<TaskTimerSummary>(logsResult.failure);
      }

      final logs = (logsResult as Success<List<TimeLog>>).value;
      final now = DateTime.now();

      // Calculate total tracked seconds
      int totalSeconds = 0;
      bool hasActiveTimer = false;

      for (final log in logs) {
        if (log.isActive) {
          hasActiveTimer = true;
          totalSeconds += log.durationSeconds(now);
        } else if (log.endTime != null) {
          totalSeconds += log.durationSeconds(log.endTime!);
        }
      }

      return Success(TaskTimerSummary(
        taskId: taskId,
        totalTrackedSeconds: totalSeconds,
        hasActiveTimer: hasActiveTimer,
      ));
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  @override
  Future<Result<List<TaskTimerSummary>>> getCompletedTasksHistory() async {
    try {
      final allLogsResult = await localDataSource.getAllTimeLogs();
      if (allLogsResult is Error<List<TimeLog>>) {
        return Error<List<TaskTimerSummary>>(allLogsResult.failure);
      }

      final allLogs = (allLogsResult as Success<List<TimeLog>>).value;

      // Group logs by taskId
      final Map<String, List<TimeLog>> logsByTask = {};
      for (final log in allLogs) {
        if (!log.isActive) {
          // Only include completed logs
          logsByTask.putIfAbsent(log.taskId, () => []).add(log);
        }
      }

      // Calculate summaries for each task
      final summaries = <TaskTimerSummary>[];
      for (final entry in logsByTask.entries) {
        int totalSeconds = 0;
        for (final log in entry.value) {
          if (log.endTime != null) {
            totalSeconds += log.durationSeconds(log.endTime!);
          }
        }

        summaries.add(TaskTimerSummary(
          taskId: entry.key,
          totalTrackedSeconds: totalSeconds,
          hasActiveTimer: false,
        ));
      }

      return Success(summaries);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }
}

