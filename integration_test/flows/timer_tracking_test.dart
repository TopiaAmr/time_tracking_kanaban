import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../helpers/test_app.dart';
import '../robots/kanban_robot.dart';
import '../robots/task_detail_robot.dart';
import '../robots/timer_robot.dart';

/// Integration tests for Timer Tracking flows.
///
/// Tests the core timer functionality including:
/// - Flow 2.1: Start Timer on Task
/// - Flow 2.2: Only One Active Timer
/// - Flow 2.3: Timer Persistence (App Restart)
/// - Flow 2.4: Auto-Stop Timer on Task Completion
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late KanbanRobot kanbanRobot;
  late TaskDetailRobot taskDetailRobot;
  late TimerRobot timerRobot;

  setUpAll(() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    // Dependencies will be initialized by IntegrationTestHelper.pumpApp
  });

  group('Flow 2.1: Start Timer on Task', () {
    testWidgets('should display timer section on task detail', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Find and tap a task to open details
      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Scroll to timer section if needed
        await taskDetailRobot.scrollToTimer();

        // Verify timer section is visible
        await timerRobot.verifyTimerSectionVisible();
      }
    });

    testWidgets('should start timer when tapping start button', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Open a task
      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Scroll to timer section
        await taskDetailRobot.scrollToTimer();

        // Start the timer
        await timerRobot.startTimer();

        // Verify timer is running
        await timerRobot.verifyTimerRunning();
      }
    });

    testWidgets('should show elapsed time after starting timer', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Open a task
      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        await taskDetailRobot.scrollToTimer();

        // Start timer
        await timerRobot.startTimer();

        // Wait for a few seconds
        await timerRobot.waitForTimerTick(const Duration(seconds: 2));

        // Verify timer display format
        await timerRobot.verifyTimerDisplayFormat();
      }
    });

    testWidgets('should pause timer when tapping pause button', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        await taskDetailRobot.scrollToTimer();

        // Start timer
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Pause timer
        await timerRobot.pauseTimer();

        // Verify timer is paused
        await timerRobot.verifyTimerPaused();
      }
    });

    testWidgets('should resume timer after pausing', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        await taskDetailRobot.scrollToTimer();

        // Start, pause, then resume
        await timerRobot.startTimer();
        await timerRobot.pauseTimer();
        await timerRobot.resumeTimer();

        // Verify timer is running again
        await timerRobot.verifyTimerRunning();
      }
    });

    testWidgets('should stop timer when tapping stop button', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        await taskDetailRobot.scrollToTimer();

        // Start timer
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Stop timer
        await timerRobot.stopTimer();

        // Verify timer is stopped
        await timerRobot.verifyTimerStopped();
      }
    });
  });

  group('Flow 2.2: Only One Active Timer', () {
    testWidgets('should stop previous timer when starting new one', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().length >= 2) {
        // Start timer on first task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Go back to Kanban
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Open second task
        await tester.tap(taskCards.at(1));
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();

        // Start timer on second task
        await timerRobot.startTimer();

        // Verify timer is running on second task
        await timerRobot.verifyTimerRunning();

        // Go back and check first task
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();

        // First task timer should be stopped
        await timerRobot.verifyTimerStopped();
      }
    });
  });

  group('Flow 2.3: Timer Persistence', () {
    testWidgets('should persist timer state across navigation', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Start timer on a task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Wait a bit
        await timerRobot.waitForTimerTick(const Duration(seconds: 1));

        // Navigate away
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Navigate back to the same task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();

        // Timer should still be running
        await timerRobot.verifyTimerRunning();
      }
    });
  });

  group('Floating Timer Widget', () {
    testWidgets('should show floating timer when timer is active', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Start timer on a task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();

        // Navigate back to Kanban
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Floating timer should be visible
        // Note: This depends on the floating timer implementation
        await timerRobot.verifyFloatingTimerVisible();
      }
    });
  });

  group('Timer Display', () {
    testWidgets('should display total time tracked', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();

        // Verify total time tracked section exists
        expect(find.text('Total Time Tracked'), findsOneWidget);
      }
    });
  });

  group('Flow 2.4: Auto-Stop Timer on Task Completion', () {
    testWidgets('should auto-stop timer when task is completed', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Open a task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Scroll to timer section and start timer
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Wait a bit for timer to accumulate time
        await timerRobot.waitForTimerTick(const Duration(seconds: 2));

        // Complete the task
        await taskDetailRobot.tapCompleteTask();
        await taskDetailRobot.confirmCompleteTask();

        // Timer should be stopped automatically
        // The pause button should no longer be visible
        await timerRobot.verifyTimerStopped();
      }
    });

    testWidgets('should preserve elapsed time when timer auto-stops on completion', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Open a task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Scroll to timer section and start timer
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();

        // Wait for timer to accumulate some time
        await timerRobot.waitForTimerTick(const Duration(seconds: 3));

        // Get the elapsed time before completion
        final elapsedTimeBefore = await timerRobot.getCurrentDisplayedTime();

        // Complete the task
        await taskDetailRobot.tapCompleteTask();
        await taskDetailRobot.confirmCompleteTask();

        // Verify timer stopped but time is preserved (not reset to 00:00)
        if (elapsedTimeBefore != null && elapsedTimeBefore != '00:00') {
          await timerRobot.verifyElapsedTimeGreaterThanZero();
        }
      }
    });

    testWidgets('should not affect timer of other tasks when completing a task', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().length >= 2) {
        // Start timer on first task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Go back to Kanban
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Open second task (which has no timer running)
        await tester.tap(taskCards.at(1));
        await tester.pumpAndSettle();

        // Complete the second task
        await taskDetailRobot.tapCompleteTask();
        await taskDetailRobot.confirmCompleteTask();

        // Go back to Kanban
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Open first task again
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();

        // Timer on first task should still be running
        await timerRobot.verifyTimerRunning();
      }
    });
  });
}
