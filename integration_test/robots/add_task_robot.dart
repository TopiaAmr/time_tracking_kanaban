import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with the Add Task dialog.
///
/// Encapsulates all add task dialog UI interactions for cleaner tests.
class AddTaskRobot {
  final WidgetTester tester;

  AddTaskRobot(this.tester);

  /// Verifies the add task dialog is displayed.
  Future<void> verifyDialogDisplayed() async {
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
  }

  /// Enters the task title.
  Future<void> enterTitle(String title) async {
    // Find the title field (usually first TextFormField)
    final titleField = find.byType(TextFormField).first;
    await tester.enterText(titleField, title);
    await tester.pumpAndSettle();
  }

  /// Enters the task description.
  Future<void> enterDescription(String description) async {
    // Find the description field (usually second TextFormField)
    final descriptionFields = find.byType(TextFormField);
    if (descriptionFields.evaluate().length > 1) {
      await tester.enterText(descriptionFields.at(1), description);
      await tester.pumpAndSettle();
    }
  }

  /// Taps the save/add button.
  Future<void> tapSave() async {
    // Find the add/save button
    final addButton = find.widgetWithText(ElevatedButton, 'Add Task');
    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton.first);
      await tester.pumpAndSettle();
    } else {
      // Try finding just "Add" or "Save"
      final saveButton = find.widgetWithText(ElevatedButton, 'Save');
      if (saveButton.evaluate().isNotEmpty) {
        await tester.tap(saveButton.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Taps the cancel button.
  Future<void> tapCancel() async {
    final cancelButton = find.text('Cancel');
    if (cancelButton.evaluate().isNotEmpty) {
      await tester.tap(cancelButton.first);
      await tester.pumpAndSettle();
    } else {
      // Try close icon
      final closeIcon = find.byIcon(Icons.close);
      if (closeIcon.evaluate().isNotEmpty) {
        await tester.tap(closeIcon.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Creates a task with the given title and description.
  Future<void> createTask({
    required String title,
    String? description,
  }) async {
    await enterTitle(title);
    if (description != null) {
      await enterDescription(description);
    }
    await tapSave();
  }

  /// Selects a due date.
  Future<void> selectDueDate(DateTime date) async {
    // Find and tap the due date button
    final dueDateButton = find.byIcon(Icons.calendar_today);
    if (dueDateButton.evaluate().isNotEmpty) {
      await tester.tap(dueDateButton.first);
      await tester.pumpAndSettle();
      
      // Select the date in the date picker
      // This is simplified - actual implementation depends on date picker
      final okButton = find.text('OK');
      if (okButton.evaluate().isNotEmpty) {
        await tester.tap(okButton.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Clears the due date.
  Future<void> clearDueDate() async {
    final clearButton = find.byIcon(Icons.clear);
    if (clearButton.evaluate().isNotEmpty) {
      await tester.tap(clearButton.first);
      await tester.pumpAndSettle();
    }
  }

  /// Verifies validation error is shown for empty title.
  Future<void> verifyTitleValidationError() async {
    await tester.pumpAndSettle();
    expect(find.text('Required'), findsOneWidget);
  }

  /// Verifies the dialog is closed.
  Future<void> verifyDialogClosed() async {
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  }

  /// Verifies the title field has specific text.
  Future<void> verifyTitleFieldText(String expectedText) async {
    await tester.pumpAndSettle();
    final titleField = find.byType(TextFormField).first;
    final widget = titleField.evaluate().first.widget as TextFormField;
    expect(widget.controller?.text, expectedText);
  }
}
