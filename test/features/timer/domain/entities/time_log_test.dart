import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

void main() {
  group('TimeLog', () {
    const tId = 'log-1';
    const tTaskId = 'task-1';
    final tStartTime = DateTime(2024, 1, 1, 10, 0, 0);
    final tEndTime = DateTime(2024, 1, 1, 11, 30, 0);

    test('should be a valid TimeLog entity', () {
      // arrange & act
      final timeLog = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: null,
      );

      // assert
      expect(timeLog.id, tId);
      expect(timeLog.taskId, tTaskId);
      expect(timeLog.startTime, tStartTime);
      expect(timeLog.endTime, isNull);
    });

    test('isActive should return true when endTime is null', () {
      // arrange
      final timeLog = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: null,
      );

      // act & assert
      expect(timeLog.isActive, isTrue);
    });

    test('isActive should return false when endTime is not null', () {
      // arrange
      final timeLog = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: tEndTime,
      );

      // act & assert
      expect(timeLog.isActive, isFalse);
    });

    test('durationSeconds should calculate correctly for completed log', () {
      // arrange
      final timeLog = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: tEndTime,
      );

      // act
      final duration = timeLog.durationSeconds(DateTime.now());

      // assert
      expect(duration, 5400); // 1.5 hours = 5400 seconds
    });

    test('durationSeconds should use provided now for active log', () {
      // arrange
      final timeLog = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: null,
      );
      final now = DateTime(2024, 1, 1, 12, 0, 0);

      // act
      final duration = timeLog.durationSeconds(now);

      // assert
      expect(duration, 7200); // 2 hours = 7200 seconds
    });

    test('should be equal when properties match', () {
      // arrange
      final timeLog1 = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: null,
      );
      final timeLog2 = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: null,
      );

      // act & assert
      expect(timeLog1, equals(timeLog2));
    });

    test('should not be equal when properties differ', () {
      // arrange
      final timeLog1 = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: null,
      );
      final timeLog2 = TimeLog(
        id: tId,
        taskId: tTaskId,
        startTime: tStartTime,
        endTime: tEndTime,
      );

      // act & assert
      expect(timeLog1, isNot(equals(timeLog2)));
    });
  });
}
