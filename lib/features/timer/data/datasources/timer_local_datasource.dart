import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

/// Local datasource for storing and retrieving time logs.
///
/// This datasource handles all local database operations for time tracking,
/// including storing timer records and retrieving time logs for tasks.
@injectable
class TimerLocalDataSource {
  final AppDatabase _db;

  TimerLocalDataSource(this._db);

  /// Inserts a new time log into the database.
  Future<Result<TimeLog>> insertTimeLog(TimeLog timeLog) async {
    try {
      await _db
          .into(_db.timeLogsTable)
          .insert(
            TimeLogsTableCompanion(
              id: Value(timeLog.id),
              taskId: Value(timeLog.taskId),
              startTime: Value(timeLog.startTime),
              endTime: Value(timeLog.endTime),
            ),
            mode: InsertMode.replace,
          );
      return Success(timeLog);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Updates an existing time log in the database.
  Future<Result<TimeLog>> updateTimeLog(TimeLog timeLog) async {
    try {
      await (_db.update(
        _db.timeLogsTable,
      )..where((tbl) => tbl.id.equals(timeLog.id))).write(
        TimeLogsTableCompanion(
          taskId: Value(timeLog.taskId),
          startTime: Value(timeLog.startTime),
          endTime: Value(timeLog.endTime),
        ),
      );
      return Success(timeLog);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves the currently active time log (one with null endTime).
  Future<Result<TimeLog?>> getActiveTimeLog() async {
    try {
      final allLogs = await _db.select(_db.timeLogsTable).get();
      final activeLog = allLogs.where((row) => row.endTime == null).firstOrNull;
      if (activeLog == null) {
        return const Success(null);
      }
      return Success(_timeLogRowToEntity(activeLog));
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves all time logs for a specific task.
  Future<Result<List<TimeLog>>> getTimeLogsForTask(String taskId) async {
    try {
      final query = _db.select(_db.timeLogsTable)
        ..where((tbl) => tbl.taskId.equals(taskId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]);
      final rows = await query.get();
      final timeLogs = rows.map((row) => _timeLogRowToEntity(row)).toList();
      return Success(timeLogs);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves all time logs from the database.
  Future<Result<List<TimeLog>>> getAllTimeLogs() async {
    try {
      final query = _db.select(_db.timeLogsTable)
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.startTime)]);
      final rows = await query.get();
      final timeLogs = rows.map((row) => _timeLogRowToEntity(row)).toList();
      return Success(timeLogs);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Deletes a time log from the database.
  Future<Result<void>> deleteTimeLog(String id) async {
    try {
      await (_db.delete(
        _db.timeLogsTable,
      )..where((tbl) => tbl.id.equals(id))).go();
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Helper method to convert database row to entity
  TimeLog _timeLogRowToEntity(TimeLogsTableData row) {
    return TimeLog(
      id: row.id,
      taskId: row.taskId,
      startTime: row.startTime,
      endTime: row.endTime,
    );
  }
}
