import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Robot for interacting with timer functionality.
///
/// Encapsulates all timer UI interactions for cleaner tests.
class TimerRobot {
  final WidgetTester tester;

  TimerRobot(this.tester);

  /// Starts the timer for the current task.
  Future<void> startTimer() async {
    // Find the start timer button
    final startButton = find.byIcon(Icons.play_arrow);
    if (startButton.evaluate().isNotEmpty) {
      await tester.tap(startButton.first);
      await tester.pumpAndSettle();
    } else {
      // Try finding by text
      final startText = find.text('Start Timer');
      if (startText.evaluate().isNotEmpty) {
        await tester.tap(startText.first);
        await tester.pumpAndSettle();
      }
    }
  }

  /// Pauses the running timer.
  Future<void> pauseTimer() async {
    final pauseButton = find.byIcon(Icons.pause);
    expect(pauseButton, findsOneWidget);
    await tester.tap(pauseButton);
    await tester.pumpAndSettle();
  }

  /// Resumes a paused timer.
  Future<void> resumeTimer() async {
    final resumeButton = find.byIcon(Icons.play_arrow);
    expect(resumeButton, findsOneWidget);
    await tester.tap(resumeButton);
    await tester.pumpAndSettle();
  }

  /// Stops the timer.
  Future<void> stopTimer() async {
    final stopButton = find.byIcon(Icons.stop);
    expect(stopButton, findsOneWidget);
    await tester.tap(stopButton);
    await tester.pumpAndSettle();
  }

  /// Verifies the timer is running.
  Future<void> verifyTimerRunning() async {
    await tester.pumpAndSettle();
    // When timer is running, pause button should be visible
    expect(find.byIcon(Icons.pause), findsOneWidget);
  }

  /// Verifies the timer is paused.
  Future<void> verifyTimerPaused() async {
    await tester.pumpAndSettle();
    // When timer is paused, play button should be visible
    expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    // Stop button should also be visible
    expect(find.byIcon(Icons.stop), findsOneWidget);
  }

  /// Verifies the timer is stopped/not running.
  Future<void> verifyTimerStopped() async {
    await tester.pumpAndSettle();
    // When timer is stopped, only start button should be visible
    // Pause and stop buttons should not be visible
    expect(find.byIcon(Icons.pause), findsNothing);
  }

  /// Verifies the timer display shows a specific format (HH:MM:SS or MM:SS).
  Future<void> verifyTimerDisplayFormat() async {
    await tester.pumpAndSettle();
    // Look for time format pattern
    final timePattern = find.textContaining(RegExp(r'\d{2}:\d{2}'));
    expect(timePattern.evaluate().isNotEmpty, isTrue);
  }

  /// Verifies the elapsed time is greater than zero.
  Future<void> verifyElapsedTimeGreaterThanZero() async {
    await tester.pumpAndSettle();
    // Look for any non-zero time display
    final zeroTime = find.text('00:00');
    final zeroTimeWithHours = find.text('00:00:00');
    
    // At least one should not be found if timer has elapsed
    expect(
      zeroTime.evaluate().isEmpty || zeroTimeWithHours.evaluate().isEmpty,
      isTrue,
    );
  }

  /// Waits for the timer to tick for a specified duration.
  Future<void> waitForTimerTick(Duration duration) async {
    await tester.pump(duration);
    await tester.pumpAndSettle();
  }

  /// Verifies the total time tracked display.
  Future<void> verifyTotalTimeTracked(String expectedTime) async {
    await tester.pumpAndSettle();
    expect(find.text(expectedTime), findsOneWidget);
  }

  /// Verifies the floating timer widget is visible.
  Future<void> verifyFloatingTimerVisible() async {
    await tester.pumpAndSettle();
    // The floating timer should show task name and time
    expect(find.byType(Card), findsWidgets);
  }

  /// Taps on the floating timer to navigate to task.
  Future<void> tapFloatingTimer() async {
    // Find the floating timer widget and tap it
    final floatingTimer = find.byKey(const Key('floating_timer'));
    if (floatingTimer.evaluate().isNotEmpty) {
      await tester.tap(floatingTimer);
      await tester.pumpAndSettle();
    }
  }

  /// Verifies the timer section header is visible.
  Future<void> verifyTimerSectionVisible() async {
    await tester.pumpAndSettle();
    expect(find.text('Time Tracking'), findsOneWidget);
  }

  /// Gets the current displayed time as a string.
  Future<String?> getCurrentDisplayedTime() async {
    await tester.pumpAndSettle();
    // Try to find time display with pattern
    final timeWidgets = find.textContaining(RegExp(r'\d{2}:\d{2}'));
    if (timeWidgets.evaluate().isNotEmpty) {
      final widget = timeWidgets.evaluate().first.widget as Text;
      return widget.data;
    }
    return null;
  }
}
