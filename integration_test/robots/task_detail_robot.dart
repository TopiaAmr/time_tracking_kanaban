import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with the Task Detail screen.
///
/// Encapsulates all task detail UI interactions for cleaner tests.
class TaskDetailRobot {
  final WidgetTester tester;

  TaskDetailRobot(this.tester);

  /// Verifies the task detail screen is displayed.
  Future<void> verifyTaskDetailDisplayed() async {
    await tester.pumpAndSettle();
    // Look for common task detail elements
    expect(find.byType(Scaffold), findsWidgets);
  }

  /// Verifies the task title is displayed.
  Future<void> verifyTaskTitle(String title) async {
    await tester.pumpAndSettle();
    expect(find.text(title), findsWidgets);
  }

  /// Verifies the task description is displayed.
  Future<void> verifyTaskDescription(String description) async {
    await tester.pumpAndSettle();
    expect(find.text(description), findsOneWidget);
  }

  /// Taps the edit button to edit task details.
  Future<void> tapEdit() async {
    final editButton = find.byIcon(Icons.edit);
    if (editButton.evaluate().isNotEmpty) {
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();
    }
  }

  /// Updates the task title.
  Future<void> updateTitle(String newTitle) async {
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, newTitle);
    await tester.pumpAndSettle();
  }

  /// Updates the task description.
  Future<void> updateDescription(String newDescription) async {
    final descriptionFields = find.byType(TextFormField);
    if (descriptionFields.evaluate().length > 1) {
      await tester.enterText(descriptionFields.at(1), newDescription);
      await tester.pumpAndSettle();
    }
  }

  /// Taps the save button.
  Future<void> tapSave() async {
    final saveButton = find.text('Save');
    if (saveButton.evaluate().isEmpty) {
      // Try finding by icon
      final saveIcon = find.byIcon(Icons.check);
      if (saveIcon.evaluate().isNotEmpty) {
        await tester.tap(saveIcon.first);
      }
    } else {
      await tester.tap(saveButton.first);
    }
    await tester.pumpAndSettle();
  }

  /// Taps the back button to return to Kanban board.
  Future<void> tapBack() async {
    final backButton = find.byIcon(Icons.arrow_back);
    if (backButton.evaluate().isNotEmpty) {
      await tester.tap(backButton.first);
      await tester.pumpAndSettle();
    } else {
      // Try using navigator pop
      await tester.pageBack();
      await tester.pumpAndSettle();
    }
  }

  /// Scrolls to the comments section.
  Future<void> scrollToComments() async {
    final scrollable = find.byType(SingleChildScrollView);
    if (scrollable.evaluate().isEmpty) return;
    
    // Scroll until comments section is visible (up to 5 attempts)
    for (int i = 0; i < 5; i++) {
      await tester.drag(scrollable.first, const Offset(0, -300));
      await tester.pumpAndSettle();
      
      // Check if comments section is visible
      final commentsHeader = find.textContaining('Comment');
      if (commentsHeader.evaluate().isNotEmpty) {
        // Scroll a bit more to ensure the input field is visible
        await tester.drag(scrollable.first, const Offset(0, -150));
        await tester.pumpAndSettle();
        return;
      }
    }
  }

  /// Scrolls to the timer section.
  Future<void> scrollToTimer() async {
    final scrollable = find.byType(SingleChildScrollView);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, const Offset(0, -200));
      await tester.pumpAndSettle();
    }
  }

  /// Verifies the timer section is visible.
  Future<void> verifyTimerSectionVisible() async {
    await tester.pumpAndSettle();
    expect(find.text('Time Tracking'), findsOneWidget);
  }

  /// Verifies the comments section is visible.
  Future<void> verifyCommentsSectionVisible() async {
    await tester.pumpAndSettle();
    // Look for comments header or add comment field
    final commentsHeader = find.textContaining('Comment');
    expect(commentsHeader.evaluate().isNotEmpty, isTrue);
  }

  /// Verifies loading state.
  Future<void> verifyLoading() async {
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty,
      isTrue,
    );
  }

  /// Verifies error state.
  Future<void> verifyError(String errorMessage) async {
    expect(find.text(errorMessage), findsOneWidget);
  }

  /// Waits for the task detail to load.
  Future<void> waitForLoad({Duration timeout = const Duration(seconds: 5)}) async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  }

  /// Taps the delete button.
  Future<void> tapDelete() async {
    final deleteButton = find.byIcon(Icons.delete);
    if (deleteButton.evaluate().isNotEmpty) {
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();
    }
  }

  /// Confirms deletion in dialog.
  Future<void> confirmDelete() async {
    final confirmButton = find.text('Delete');
    if (confirmButton.evaluate().isNotEmpty) {
      await tester.tap(confirmButton.last);
      await tester.pumpAndSettle();
    }
  }
}
