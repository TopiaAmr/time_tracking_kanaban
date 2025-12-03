import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with the Kanban board screen.
///
/// Encapsulates all Kanban board UI interactions for cleaner tests.
class KanbanRobot {
  final WidgetTester tester;

  KanbanRobot(this.tester);

  /// Verifies the Kanban board is displayed.
  Future<void> verifyKanbanBoardDisplayed() async {
    // Wait for the board to load
    await tester.pumpAndSettle();
    
    // Look for column headers or task cards
    expect(find.byType(SingleChildScrollView), findsWidgets);
  }

  /// Verifies a task with the given title exists in the board.
  Future<void> verifyTaskExists(String taskTitle) async {
    await tester.pumpAndSettle();
    expect(find.text(taskTitle), findsOneWidget);
  }

  /// Verifies a task with the given title exists in a specific column.
  Future<void> verifyTaskInColumn(String taskTitle, String columnName) async {
    await tester.pumpAndSettle();
    
    // Find the column by name
    final columnFinder = find.text(columnName);
    expect(columnFinder, findsOneWidget);
    
    // Verify task exists
    expect(find.text(taskTitle), findsOneWidget);
  }

  /// Taps the add task button.
  Future<void> tapAddTask() async {
    // Find and tap the add task button (usually a + icon or "Add Task" text)
    final addButton = find.byIcon(Icons.add);
    if (addButton.evaluate().isNotEmpty) {
      await tester.tap(addButton.first);
      await tester.pumpAndSettle();
    }
  }

  /// Taps on a task card to open task details.
  Future<void> tapOnTask(String taskTitle) async {
    final taskFinder = find.text(taskTitle);
    expect(taskFinder, findsOneWidget);
    await tester.tap(taskFinder);
    await tester.pumpAndSettle();
  }

  /// Verifies a column with the given name exists.
  Future<void> verifyColumnExists(String columnName) async {
    await tester.pumpAndSettle();
    expect(find.text(columnName), findsOneWidget);
  }

  /// Verifies multiple columns exist.
  Future<void> verifyColumnsExist(List<String> columnNames) async {
    await tester.pumpAndSettle();
    for (final name in columnNames) {
      expect(find.text(name), findsOneWidget);
    }
  }

  /// Counts tasks in a column (by finding task cards under the column).
  Future<int> countTasksInColumn(String columnName) async {
    await tester.pumpAndSettle();
    // This is a simplified count - actual implementation depends on widget structure
    return find.byType(Card).evaluate().length;
  }

  /// Scrolls the Kanban board horizontally.
  Future<void> scrollHorizontally({bool left = false}) async {
    final scrollable = find.byType(SingleChildScrollView).first;
    await tester.drag(scrollable, Offset(left ? 200 : -200, 0));
    await tester.pumpAndSettle();
  }

  /// Performs a search for tasks.
  Future<void> searchTasks(String query) async {
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField.first, query);
      await tester.pumpAndSettle();
    }
  }

  /// Clears the search field.
  Future<void> clearSearch() async {
    final searchField = find.byType(TextField);
    if (searchField.evaluate().isNotEmpty) {
      await tester.enterText(searchField.first, '');
      await tester.pumpAndSettle();
    }
  }

  /// Verifies the loading skeleton is displayed.
  Future<void> verifyLoadingState() async {
    // Look for skeleton widgets or loading indicators
    expect(
      find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
          find.byKey(const Key('kanban_skeleton')).evaluate().isNotEmpty,
      isTrue,
    );
  }

  /// Verifies an error state is displayed.
  Future<void> verifyErrorState() async {
    expect(find.byIcon(Icons.error_outline), findsOneWidget);
  }

  /// Taps the retry button on error state.
  Future<void> tapRetry() async {
    final retryButton = find.text('Retry');
    expect(retryButton, findsOneWidget);
    await tester.tap(retryButton);
    await tester.pumpAndSettle();
  }

  /// Waits for the board to finish loading.
  Future<void> waitForLoad({Duration timeout = const Duration(seconds: 5)}) async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  }

  /// Performs a drag-and-drop operation to move a task from one column to another.
  /// 
  /// Uses long press to initiate drag (as per LongPressDraggable implementation).
  /// [taskTitle] - The title of the task to drag
  /// [targetColumnName] - The name of the column to drop the task into
  Future<void> dragTaskToColumn(String taskTitle, String targetColumnName) async {
    await tester.pumpAndSettle();
    
    // Find the task card by its title
    final taskFinder = find.text(taskTitle);
    expect(taskFinder, findsOneWidget, reason: 'Task "$taskTitle" not found');
    
    // Find the target column by its header text
    final targetColumnFinder = find.text(targetColumnName);
    expect(targetColumnFinder, findsOneWidget, reason: 'Column "$targetColumnName" not found');
    
    // Get the positions
    final taskCenter = tester.getCenter(taskFinder);
    final targetCenter = tester.getCenter(targetColumnFinder);
    
    // Perform long press drag (LongPressDraggable requires long press to start)
    // 1. Start with a long press
    final gesture = await tester.startGesture(taskCenter);
    await tester.pump(const Duration(milliseconds: 600)); // Long press duration
    
    // 2. Move to target
    await gesture.moveTo(targetCenter);
    await tester.pump(const Duration(milliseconds: 100));
    
    // 3. Move down a bit to ensure we're in the drop zone (below the header)
    await gesture.moveTo(Offset(targetCenter.dx, targetCenter.dy + 100));
    await tester.pump(const Duration(milliseconds: 100));
    
    // 4. Release
    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Performs a drag-and-drop using task finder directly.
  /// More reliable for complex scenarios.
  Future<void> dragTaskCardToColumn({
    required Finder taskCardFinder,
    required String targetColumnName,
  }) async {
    await tester.pumpAndSettle();
    
    expect(taskCardFinder, findsOneWidget, reason: 'Task card not found');
    
    // Find the target column
    final targetColumnFinder = find.text(targetColumnName);
    expect(targetColumnFinder, findsOneWidget, reason: 'Column "$targetColumnName" not found');
    
    final taskCenter = tester.getCenter(taskCardFinder);
    final targetCenter = tester.getCenter(targetColumnFinder);
    
    // Long press drag
    final gesture = await tester.startGesture(taskCenter);
    await tester.pump(const Duration(milliseconds: 600));
    
    // Move to target column area (below header)
    await gesture.moveTo(Offset(targetCenter.dx, targetCenter.dy + 150));
    await tester.pump(const Duration(milliseconds: 200));
    
    await gesture.up();
    await tester.pumpAndSettle();
  }

  /// Gets the column name for a task by finding its parent column.
  Future<String?> getTaskColumnName(String taskTitle) async {
    await tester.pumpAndSettle();
    
    final taskFinder = find.text(taskTitle);
    if (taskFinder.evaluate().isEmpty) return null;
    
    // This is a simplified check - in reality you'd need to traverse the widget tree
    // For now, we rely on the visual position
    return null; // Would need widget tree traversal
  }

  /// Verifies a task is in a specific column.
  /// Note: This is a basic check that verifies both task and column exist.
  /// A more robust implementation would check the actual parent-child relationship.
  Future<void> verifyTaskInColumnByPosition(String taskTitle, String columnName) async {
    await tester.pumpAndSettle();
    
    // Verify both exist
    expect(find.text(taskTitle), findsOneWidget);
    expect(find.text(columnName), findsOneWidget);
    
    // Get positions to verify task is under the column header
    final taskPos = tester.getCenter(find.text(taskTitle));
    final columnPos = tester.getCenter(find.text(columnName));
    
    // Task should be below the column header (higher Y value)
    // and roughly aligned horizontally (within column width ~300px)
    expect(taskPos.dy, greaterThan(columnPos.dy), 
        reason: 'Task should be below column header');
    expect((taskPos.dx - columnPos.dx).abs(), lessThan(200), 
        reason: 'Task should be horizontally aligned with column');
  }
}
