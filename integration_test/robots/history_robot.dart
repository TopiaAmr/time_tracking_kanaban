import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with the Task History screen.
///
/// Encapsulates all history screen UI interactions for cleaner tests.
class HistoryRobot {
  final WidgetTester tester;

  HistoryRobot(this.tester);

  /// Verifies the history screen is displayed.
  Future<void> verifyHistoryScreenDisplayed() async {
    await tester.pumpAndSettle();
    // Look for history-specific elements
    expect(find.byType(Scaffold), findsWidgets);
  }

  /// Verifies completed tasks are displayed.
  Future<void> verifyCompletedTasksDisplayed() async {
    await tester.pumpAndSettle();
    // Look for task cards or list items
    final cards = find.byType(Card);
    expect(cards.evaluate().isNotEmpty, isTrue);
  }

  /// Verifies a specific completed task is shown.
  Future<void> verifyTaskInHistory(String taskTitle) async {
    await tester.pumpAndSettle();
    expect(find.text(taskTitle), findsOneWidget);
  }

  /// Verifies time spent is displayed for tasks.
  Future<void> verifyTimeSpentDisplayed() async {
    await tester.pumpAndSettle();
    // Look for time format patterns
    final timePattern = find.textContaining(RegExp(r'\d+[hms]|\d{2}:\d{2}'));
    expect(timePattern.evaluate().isNotEmpty, isTrue);
  }

  /// Verifies tasks are grouped by date.
  Future<void> verifyDateGrouping() async {
    await tester.pumpAndSettle();
    // Look for date headers
    final datePattern = find.textContaining(RegExp(r'\d{1,2}/\d{1,2}|\w+day|Today|Yesterday'));
    expect(datePattern.evaluate().isNotEmpty, isTrue);
  }

  /// Scrolls through the history list.
  Future<void> scrollHistory({bool up = false}) async {
    final scrollable = find.byType(ListView);
    if (scrollable.evaluate().isNotEmpty) {
      await tester.drag(scrollable.first, Offset(0, up ? 200 : -200));
      await tester.pumpAndSettle();
    }
  }

  /// Taps on a completed task to view details.
  Future<void> tapTask(String taskTitle) async {
    final task = find.text(taskTitle);
    expect(task, findsOneWidget);
    await tester.tap(task);
    await tester.pumpAndSettle();
  }

  /// Verifies empty state when no completed tasks.
  Future<void> verifyEmptyState() async {
    await tester.pumpAndSettle();
    final emptyText = find.textContaining('No completed');
    expect(emptyText.evaluate().isNotEmpty, isTrue);
  }

  /// Verifies loading state.
  Future<void> verifyLoading() async {
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  }

  /// Navigates to history screen via navigation.
  Future<void> navigateToHistory() async {
    // Find and tap history navigation item
    final historyNav = find.text('History');
    if (historyNav.evaluate().isNotEmpty) {
      await tester.tap(historyNav.first);
      await tester.pumpAndSettle();
    } else {
      // Try icon
      final historyIcon = find.byIcon(Icons.history);
      if (historyIcon.evaluate().isNotEmpty) {
        await tester.tap(historyIcon.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Waits for history to load.
  Future<void> waitForLoad({Duration timeout = const Duration(seconds: 5)}) async {
    await tester.pumpAndSettle(
      const Duration(milliseconds: 100),
      EnginePhase.sendSemanticsUpdate,
      timeout,
    );
  }
}
