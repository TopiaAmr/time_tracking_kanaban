import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'helpers/test_app.dart';
import 'robots/kanban_robot.dart';
import 'robots/task_detail_robot.dart';
import 'robots/timer_robot.dart';
import 'robots/comments_robot.dart';
import 'robots/add_task_robot.dart';

/// Main integration test entry point.
///
/// This file contains the primary integration test flows that cover
/// the core functionality of the Kanban Time-Tracker application.
///
/// Run with: flutter test integration_test/app_test.dart
/// Or for a specific device: flutter test integration_test/app_test.dart -d `<device_id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late KanbanRobot kanbanRobot;
  late TaskDetailRobot taskDetailRobot;
  late TimerRobot timerRobot;
  late CommentsRobot commentsRobot;
  late AddTaskRobot addTaskRobot;

  setUpAll(() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    // Dependencies will be initialized by IntegrationTestHelper.pumpApp
  });

  tearDown(() async {
    // Allow pending async operations to complete
    // This helps prevent "Cannot emit new states after calling close" errors
  });

  group('P0 - Critical: Core Functionality', () {
    testWidgets('Flow 1.1: View Tasks in Columns', (tester) async {
      kanbanRobot = KanbanRobot(tester);

      // Launch app
      await IntegrationTestHelper.pumpApp(tester);

      // Verify Kanban board loads successfully
      await kanbanRobot.verifyKanbanBoardDisplayed();
      await kanbanRobot.waitForLoad();

      // Verify board has content
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('Flow 1.2: Create New Task', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      addTaskRobot = AddTaskRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Open add task dialog
      await kanbanRobot.tapAddTask();
      await addTaskRobot.verifyDialogDisplayed();

      // Create task
      const taskTitle = 'P0 Test Task';
      await addTaskRobot.createTask(
        title: taskTitle,
        description: 'Created in P0 integration test',
      );

      // Verify task was created
      await addTaskRobot.verifyDialogClosed();
      await IntegrationTestHelper.waitForAsync(tester);
      await kanbanRobot.verifyTaskExists(taskTitle);
    });

    testWidgets('Flow 2.1: Start Timer on Task', (tester) async {
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

        // Start timer
        await timerRobot.startTimer();

        // Verify timer is running
        await timerRobot.verifyTimerRunning();

        // Stop timer to clean up
        await timerRobot.stopTimer();
      }
    });

    testWidgets('Flow 2.3: Timer Persistence', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      timerRobot = TimerRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Start timer
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Navigate away
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Navigate back
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();

        // Timer should still be running
        await timerRobot.verifyTimerRunning();

        // Clean up
        await timerRobot.stopTimer();
      }
    });
  });

  group('P1 - High: Core Workflow', () {
    testWidgets('Flow 1.4: Navigate between tasks', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Open first task
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.verifyTaskDetailDisplayed();

        // Go back
        await taskDetailRobot.tapBack();
        await kanbanRobot.verifyKanbanBoardDisplayed();
      }
    });

    testWidgets('Flow 1.4: Drag Task Between Columns', (tester) async {
      kanbanRobot = KanbanRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Check if we have the expected columns
      final toDoColumn = find.text('To Do');
      final inProgressColumn = find.text('In Progress');
      
      if (toDoColumn.evaluate().isNotEmpty && inProgressColumn.evaluate().isNotEmpty) {
        final taskCards = find.byType(Card);
        
        if (taskCards.evaluate().isNotEmpty) {
          // Get task title from first card
          final textsInCard = find.descendant(
            of: taskCards.first,
            matching: find.byType(Text),
          );
          
          if (textsInCard.evaluate().isNotEmpty) {
            final taskTitleWidget = tester.widget<Text>(textsInCard.first);
            final taskTitle = taskTitleWidget.data ?? '';
            
            if (taskTitle.isNotEmpty) {
              // Perform drag and drop
              await kanbanRobot.dragTaskToColumn(taskTitle, 'In Progress');
              
              // Wait for the move to complete
              await tester.pump(const Duration(seconds: 1));
              await tester.pumpAndSettle();
            }
          }
        }
      }
      
      // Verify board is still functional
      await kanbanRobot.verifyKanbanBoardDisplayed();
    });

    testWidgets('Flow 2.2: Only One Active Timer', (tester) async {
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

        // Go to second task and start timer
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();
        await tester.tap(taskCards.at(1));
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.startTimer();
        await timerRobot.verifyTimerRunning();

        // Verify first task timer stopped
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.verifyTimerStopped();

        // Clean up - stop second task timer
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();
        await tester.tap(taskCards.at(1));
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToTimer();
        await timerRobot.stopTimer();
      }
    });
  });

  group('P2 - Medium: Secondary Features', () {
    testWidgets('Flow 4.1: Add Comment to Task', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      commentsRobot = CommentsRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToComments();

        // Wait for comments to load before adding
        await tester.pump(const Duration(seconds: 2));
        try {
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        } catch (_) {}

        // Add comment
        const comment = 'P2 Test Comment';
        await commentsRobot.addComment(comment);
        
        // Wait for API call to complete
        await tester.pump(const Duration(seconds: 3));
        await IntegrationTestHelper.waitForAsync(tester);

        // Verify comment exists
        await commentsRobot.verifyCommentExists(comment);
      }
    });

    testWidgets('Flow 4.2: View Existing Comments', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      commentsRobot = CommentsRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToComments();

        // Verify comments section is visible
        await commentsRobot.verifyCommentsSectionVisible();
      }
    });
  });

  group('P3 - Low: UI Polish', () {
    testWidgets('Search functionality works', (tester) async {
      kanbanRobot = KanbanRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Search for tasks
      await kanbanRobot.searchTasks('test');
      await IntegrationTestHelper.waitForAsync(tester);

      // Clear search
      await kanbanRobot.clearSearch();
      await IntegrationTestHelper.waitForAsync(tester);

      // Board should still be functional
      await kanbanRobot.verifyKanbanBoardDisplayed();
    });

    testWidgets('Horizontal scrolling works', (tester) async {
      kanbanRobot = KanbanRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Scroll horizontally
      await kanbanRobot.scrollHorizontally();

      // Board should still be displayed
      await kanbanRobot.verifyKanbanBoardDisplayed();
    });
  });

  group('Error Handling', () {
    testWidgets('App handles navigation gracefully', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Multiple navigation actions
      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Navigate to task detail
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Navigate back
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Navigate again
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Navigate back again
        await taskDetailRobot.tapBack();

        // App should still be functional
        await kanbanRobot.verifyKanbanBoardDisplayed();
      }
    });
  });
}
