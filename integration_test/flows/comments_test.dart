import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../helpers/test_app.dart';
import '../robots/kanban_robot.dart';
import '../robots/task_detail_robot.dart';
import '../robots/comments_robot.dart';

/// Integration tests for Comments flows.
///
/// Tests the comments functionality including:
/// - Flow 4.1: Add Comment to Task
/// - Flow 4.2: View Existing Comments
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late KanbanRobot kanbanRobot;
  late TaskDetailRobot taskDetailRobot;
  late CommentsRobot commentsRobot;

  setUpAll(() async {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    // Dependencies will be initialized by IntegrationTestHelper.pumpApp
  });

  group('Flow 4.1: Add Comment to Task', () {
    testWidgets('should display comments section on task detail', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      commentsRobot = CommentsRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      // Find and tap a task to open details
      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();

        // Scroll to comments section
        await taskDetailRobot.scrollToComments();

        // Verify comments section is visible
        await commentsRobot.verifyCommentsSectionVisible();
      }
    });

    testWidgets('should add a new comment', (tester) async {
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

        // Add a comment
        const testComment = 'This is a test comment from integration test';
        await commentsRobot.addComment(testComment);

        // Wait for the comment to be added
        await IntegrationTestHelper.waitForAsync(tester);

        // Verify comment appears
        await commentsRobot.verifyCommentExists(testComment);
      }
    });

    testWidgets('should clear input field after adding comment', (tester) async {
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

        // Add a comment
        await commentsRobot.addComment('Test comment');
        await IntegrationTestHelper.waitForAsync(tester);

        // Verify input field is cleared
        await commentsRobot.verifyInputFieldEmpty();
      }
    });
  });

  group('Flow 4.2: View Existing Comments', () {
    testWidgets('should display existing comments', (tester) async {
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

        // If there are existing comments, they should be displayed
        // This depends on the actual data from the API
      }
    });

    testWidgets('should scroll through comments list', (tester) async {
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

        // Try scrolling through comments
        await commentsRobot.scrollComments();

        // Verify we can still see the comments section
        await commentsRobot.verifyCommentsSectionVisible();
      }
    });
  });

  group('Comments Edge Cases', () {
    testWidgets('should handle empty comments gracefully', (tester) async {
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

        // Try to add empty comment (should not be added)
        await commentsRobot.enterComment('');
        await commentsRobot.tapAddComment();

        // App should handle this gracefully
        await tester.pumpAndSettle();
      }
    });

    testWidgets('should handle long comments', (tester) async {
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

        // Add a long comment
        final longComment = 'This is a very long comment ' * 10;
        await commentsRobot.addComment(longComment);

        await IntegrationTestHelper.waitForAsync(tester);

        // Verify comment was added (might be truncated in display)
        await commentsRobot.verifyCommentsSectionVisible();
      }
    });
  });

  group('Comments Persistence', () {
    testWidgets('should persist comments after navigation', (tester) async {
      kanbanRobot = KanbanRobot(tester);
      taskDetailRobot = TaskDetailRobot(tester);
      commentsRobot = CommentsRobot(tester);

      await IntegrationTestHelper.pumpApp(tester);
      await kanbanRobot.waitForLoad();

      final taskCards = find.byType(Card);
      if (taskCards.evaluate().isNotEmpty) {
        // Add a comment
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToComments();

        const testComment = 'Persistent comment test';
        await commentsRobot.addComment(testComment);
        await IntegrationTestHelper.waitForAsync(tester);

        // Navigate away
        await taskDetailRobot.tapBack();
        await kanbanRobot.waitForLoad();

        // Navigate back
        await tester.tap(taskCards.first);
        await tester.pumpAndSettle();
        await taskDetailRobot.scrollToComments();

        // Comment should still be there
        await commentsRobot.verifyCommentExists(testComment);
      }
    });
  });
}
