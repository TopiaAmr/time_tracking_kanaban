import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:time_tracking_kanaban/features/timer/data/datasources/timer_local_datasource.dart';
import 'package:time_tracking_kanaban/features/timer/data/repositories/timer_repository_impl.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import '../../../../mocks/mock_setup.dart';

void main() {
  late AppDatabase database;
  late TimerLocalDataSource localDataSource;
  late TimerRepositoryImpl repository;

  setUp(() {
    setupMockDummyValues();
    database = AppDatabase(LazyDatabase(() async => NativeDatabase.memory()));
    localDataSource = TimerLocalDataSource(database);
    final tasksLocalDataSource = TasksLocalDataSource(database);
    repository = TimerRepositoryImpl(localDataSource, tasksLocalDataSource);
  });

  tearDown(() async {
    await database.close();
  });

  group('TimerRepositoryImpl', () {
    test('should start a timer and stop any existing active timer', () async {
      final now = DateTime.now();
      // Create an existing active timer
      final existingLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: null,
      );
      await localDataSource.insertTimeLog(existingLog);

      final result = await repository.startTimer('task2');

      expect(result, isA<Success<TimeLog>>());
      if (result is Success<TimeLog>) {
        expect(result.value.taskId, equals('task2'));
        expect(result.value.isActive, isTrue);
      }

      // Verify old timer was stopped
      final activeResult = await repository.getActiveTimer();
      if (activeResult is Success<TimeLog?>) {
        expect(activeResult.value?.taskId, equals('task2'));
      }
    });

    test('should pause an active timer', () async {
      final now = DateTime.now();
      final activeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: null,
      );
      await localDataSource.insertTimeLog(activeLog);

      final result = await repository.pauseTimer();

      expect(result, isA<Success<TimeLog>>());
      if (result is Success<TimeLog>) {
        expect(result.value.isActive, isFalse);
        expect(result.value.endTime, isNotNull);
      }
    });

    test('should return error when pausing with no active timer', () async {
      final result = await repository.pauseTimer();

      expect(result, isA<Error<TimeLog>>());
    });

    test('should stop an active timer', () async {
      final now = DateTime.now();
      final activeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: null,
      );
      await localDataSource.insertTimeLog(activeLog);

      final result = await repository.stopTimer();

      expect(result, isA<Success<TimeLog>>());
      if (result is Success<TimeLog>) {
        expect(result.value.isActive, isFalse);
        expect(result.value.endTime, isNotNull);
      }
    });

    test('should get task timer summary', () async {
      final now = DateTime.now();
      final log1 = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      final log2 = TimeLog(
        id: 'timer2',
        taskId: 'task1',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: now,
      );

      await localDataSource.insertTimeLog(log1);
      await localDataSource.insertTimeLog(log2);

      final result = await repository.getTaskTimerSummary('task1');

      expect(result, isA<Success<TaskTimerSummary>>());
      if (result is Success<TaskTimerSummary>) {
        expect(result.value.taskId, equals('task1'));
        expect(result.value.totalTrackedSeconds, greaterThan(0));
        expect(result.value.hasActiveTimer, isFalse);
      }
    });

    test('should get completed tasks history', () async {
      final now = DateTime.now();
      final log1 = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      final log2 = TimeLog(
        id: 'timer2',
        taskId: 'task2',
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 2)),
      );

      await localDataSource.insertTimeLog(log1);
      await localDataSource.insertTimeLog(log2);

      final result = await repository.getCompletedTasksHistory();

      expect(result, isA<Success<List<TaskTimerSummary>>>());
      if (result is Success<List<TaskTimerSummary>>) {
        expect(result.value.length, equals(2));
        expect(result.value.any((s) => s.taskId == 'task1'), isTrue);
        expect(result.value.any((s) => s.taskId == 'task2'), isTrue);
      }
    });

    test('should include tasks with active timers in history if they have completed logs', () async {
      final now = DateTime.now();
      // Task with completed log
      final completedLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1)),
      );
      // Same task with active timer
      final activeLog = TimeLog(
        id: 'timer2',
        taskId: 'task1',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: null,
      );

      await localDataSource.insertTimeLog(completedLog);
      await localDataSource.insertTimeLog(activeLog);

      final result = await repository.getCompletedTasksHistory();

      expect(result, isA<Success<List<TaskTimerSummary>>>());
      if (result is Success<List<TaskTimerSummary>>) {
        expect(result.value.length, equals(1));
        final summary = result.value.first;
        expect(summary.taskId, equals('task1'));
        expect(summary.hasActiveTimer, isTrue);
        expect(summary.totalTrackedSeconds, greaterThan(0));
      }
    });

    test('should not include tasks with only active timers and no completed logs', () async {
      final now = DateTime.now();
      // Task with only active timer, no completed logs
      final activeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now.subtract(const Duration(minutes: 30)),
        endTime: null,
      );

      await localDataSource.insertTimeLog(activeLog);

      final result = await repository.getCompletedTasksHistory();

      expect(result, isA<Success<List<TaskTimerSummary>>>());
      if (result is Success<List<TaskTimerSummary>>) {
        expect(result.value.length, equals(0));
      }
    });
  });
}
