import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/di.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/cubit/task_history_cubit.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/cubit/task_history_state.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/screens/task_history_screen.dart';

import '../../../../core/widgets/widget_test_helpers.dart';
import 'task_history_screen_test.mocks.dart';

@GenerateMocks([TaskHistoryCubit])
void main() {
  group('TaskHistoryScreen', () {
    tearDown(() {
      // Clean up getIt after each test
      if (getIt.isRegistered<TaskHistoryCubit>()) {
        getIt.unregister<TaskHistoryCubit>();
      }
    });

    /// Helper to create and register a mock cubit in getIt
    MockTaskHistoryCubit setupMockCubit({TaskHistoryState? initialState}) {
      // Clean up any existing registration first
      if (getIt.isRegistered<TaskHistoryCubit>()) {
        getIt.unregister<TaskHistoryCubit>();
      }

      final mock = MockTaskHistoryCubit();
      final state = initialState ?? const TaskHistoryLoading();

      // Stub all methods and properties - must be done before mock is accessed
      // Use thenAnswer for async methods to ensure proper Future<void> return type
      when(mock.loadHistory()).thenAnswer((_) async {});
      when(mock.state).thenReturn(state);
      when(mock.stream).thenAnswer(
        (_) => Stream<TaskHistoryState>.value(state).asBroadcastStream(),
      );

      // Register mock cubit in getIt as a factory that returns the same instance
      getIt.registerFactory<TaskHistoryCubit>(() => mock);

      return mock;
    }

    testWidgets('displays loading indicator when state is loading', (
      WidgetTester tester,
    ) async {
      setupMockCubit(initialState: const TaskHistoryLoading());

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is error', (
      WidgetTester tester,
    ) async {
      setupMockCubit(initialState: const TaskHistoryError(ServerFailure()));

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls retry when retry button is tapped', (
      WidgetTester tester,
    ) async {
      final mockCubit = setupMockCubit(
        initialState: const TaskHistoryError(ServerFailure()),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      // Clear the initial call from screen init
      clearInteractions(mockCubit);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Verify loadHistory was called when retry button was tapped
      verify(mockCubit.loadHistory()).called(1);
    });

    testWidgets('displays empty state when no summaries', (
      WidgetTester tester,
    ) async {
      setupMockCubit(initialState: const TaskHistoryLoaded([]));

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      expect(find.byIcon(Icons.history), findsOneWidget);
      expect(find.text('No completed tasks yet'), findsOneWidget);
    });

    testWidgets('displays history list when summaries are provided', (
      WidgetTester tester,
    ) async {
      final summaries = [
        TestDataFactory.createTaskTimerSummary(
          taskId: 'task1',
          totalTrackedSeconds: 3600,
        ),
        TestDataFactory.createTaskTimerSummary(
          taskId: 'task2',
          totalTrackedSeconds: 7200,
        ),
      ];

      setupMockCubit(initialState: TaskHistoryLoaded(summaries));

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      // Find ListView in the body (not in sidebar)
      expect(find.byType(ListView), findsWidgets);
      // Should find 2 cards for the 2 summaries
      expect(find.byType(Card), findsNWidgets(2));
    });

    testWidgets('displays task ID in history items', (
      WidgetTester tester,
    ) async {
      final summaries = [
        TestDataFactory.createTaskTimerSummary(
          taskId: 'task1',
          totalTrackedSeconds: 3600,
        ),
      ];

      setupMockCubit(initialState: TaskHistoryLoaded(summaries));

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      expect(find.text('Task task1'), findsOneWidget);
    });

    testWidgets('displays formatted duration in history items', (
      WidgetTester tester,
    ) async {
      final summaries = [
        TestDataFactory.createTaskTimerSummary(
          taskId: 'task1',
          totalTrackedSeconds: 3660, // 1 hour, 1 minute
        ),
      ];

      setupMockCubit(initialState: TaskHistoryLoaded(summaries));

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      // Should display formatted duration (1h 1m)
      expect(find.text('1h 1m'), findsOneWidget);
    });

    testWidgets('displays time icon in history items', (
      WidgetTester tester,
    ) async {
      final summaries = [
        TestDataFactory.createTaskTimerSummary(
          taskId: 'task1',
          totalTrackedSeconds: 3600,
        ),
      ];

      setupMockCubit(initialState: TaskHistoryLoaded(summaries));

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('loads history on init', (WidgetTester tester) async {
      final mockCubit = setupMockCubit(
        initialState: const TaskHistoryLoading(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(child: const TaskHistoryScreen()),
      );

      // The screen uses BlocProvider.create which calls loadHistory on the cubit
      // Since we've registered our mock in getIt, it will use our mock
      verify(mockCubit.loadHistory()).called(1);
    });
  });
}
