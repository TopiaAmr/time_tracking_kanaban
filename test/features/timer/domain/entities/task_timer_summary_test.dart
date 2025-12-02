import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';

void main() {
  group('TaskTimerSummary', () {
    const tTaskId = 'task-1';
    const tTotalSeconds = 3600; // 1 hour

    test('should be a valid TaskTimerSummary entity', () {
      // arrange & act
      const summary = TaskTimerSummary(
        taskId: tTaskId,
        totalTrackedSeconds: tTotalSeconds,
        hasActiveTimer: false,
      );

      // assert
      expect(summary.taskId, tTaskId);
      expect(summary.totalTrackedSeconds, tTotalSeconds);
      expect(summary.hasActiveTimer, isFalse);
    });

    test('totalTrackedDuration should return correct Duration', () {
      // arrange
      const summary = TaskTimerSummary(
        taskId: tTaskId,
        totalTrackedSeconds: tTotalSeconds,
        hasActiveTimer: false,
      );

      // act
      final duration = summary.totalTrackedDuration;

      // assert
      expect(duration.inSeconds, tTotalSeconds);
      expect(duration.inHours, 1);
    });

    test('should be equal when properties match', () {
      // arrange
      const summary1 = TaskTimerSummary(
        taskId: tTaskId,
        totalTrackedSeconds: tTotalSeconds,
        hasActiveTimer: false,
      );
      const summary2 = TaskTimerSummary(
        taskId: tTaskId,
        totalTrackedSeconds: tTotalSeconds,
        hasActiveTimer: false,
      );

      // act & assert
      expect(summary1, equals(summary2));
    });

    test('should not be equal when properties differ', () {
      // arrange
      const summary1 = TaskTimerSummary(
        taskId: tTaskId,
        totalTrackedSeconds: tTotalSeconds,
        hasActiveTimer: false,
      );
      const summary2 = TaskTimerSummary(
        taskId: tTaskId,
        totalTrackedSeconds: tTotalSeconds,
        hasActiveTimer: true,
      );

      // act & assert
      expect(summary1, isNot(equals(summary2)));
    });
  });
}
