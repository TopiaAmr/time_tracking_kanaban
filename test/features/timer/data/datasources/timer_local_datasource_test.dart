import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/data/datasources/timer_local_datasource.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

void main() {
  late AppDatabase database;
  late TimerLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase(LazyDatabase(() async => NativeDatabase.memory()));
    dataSource = TimerLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('TimerLocalDataSource', () {
    test('should insert and retrieve a time log', () async {
      final now = DateTime.now();
      final timeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: null,
      );

      final insertResult = await dataSource.insertTimeLog(timeLog);
      expect(insertResult, isA<Success<TimeLog>>());

      final retrieveResult = await dataSource.getTimeLogsForTask('task1');
      expect(retrieveResult, isA<Success<List<TimeLog>>>());
      if (retrieveResult is Success<List<TimeLog>>) {
        expect(retrieveResult.value.length, equals(1));
        expect(retrieveResult.value.first.id, equals('timer1'));
        expect(retrieveResult.value.first.isActive, isTrue);
      }
    });

    test('should get active time log', () async {
      final now = DateTime.now();
      final activeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: null,
      );
      final completedLog = TimeLog(
        id: 'timer2',
        taskId: 'task2',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now,
      );

      await dataSource.insertTimeLog(activeLog);
      await dataSource.insertTimeLog(completedLog);

      final result = await dataSource.getActiveTimeLog();
      expect(result, isA<Success<TimeLog?>>());
      if (result is Success<TimeLog?>) {
        expect(result.value, isNotNull);
        expect(result.value!.id, equals('timer1'));
      }
    });

    test('should return null when no active timer exists', () async {
      final now = DateTime.now();
      final completedLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: now,
      );

      await dataSource.insertTimeLog(completedLog);

      final result = await dataSource.getActiveTimeLog();
      expect(result, isA<Success<TimeLog?>>());
      if (result is Success<TimeLog?>) {
        expect(result.value, isNull);
      }
    });

    test('should update a time log', () async {
      final now = DateTime.now();
      final timeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: null,
      );

      await dataSource.insertTimeLog(timeLog);

      final updatedLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      );

      final updateResult = await dataSource.updateTimeLog(updatedLog);
      expect(updateResult, isA<Success<TimeLog>>());

      final retrieveResult = await dataSource.getTimeLogsForTask('task1');
      if (retrieveResult is Success<List<TimeLog>>) {
        expect(retrieveResult.value.first.endTime, isNotNull);
        expect(retrieveResult.value.first.isActive, isFalse);
      }
    });

    test('should get all time logs for a task', () async {
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
      final log3 = TimeLog(
        id: 'timer3',
        taskId: 'task2',
        startTime: now,
        endTime: null,
      );

      await dataSource.insertTimeLog(log1);
      await dataSource.insertTimeLog(log2);
      await dataSource.insertTimeLog(log3);

      final result = await dataSource.getTimeLogsForTask('task1');
      if (result is Success<List<TimeLog>>) {
        expect(result.value.length, equals(2));
        expect(result.value.any((log) => log.id == 'timer1'), isTrue);
        expect(result.value.any((log) => log.id == 'timer2'), isTrue);
      }
    });

    test('should delete a time log', () async {
      final now = DateTime.now();
      final timeLog = TimeLog(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: null,
      );

      await dataSource.insertTimeLog(timeLog);

      final deleteResult = await dataSource.deleteTimeLog('timer1');
      expect(deleteResult, isA<Success<void>>());

      final retrieveResult = await dataSource.getTimeLogsForTask('task1');
      if (retrieveResult is Success<List<TimeLog>>) {
        expect(retrieveResult.value.length, equals(0));
      }
    });
  });
}
