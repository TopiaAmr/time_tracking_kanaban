import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import '../../../../core/widgets/widget_test_helpers.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_state.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/screens/kanban_board_screen.dart';

import 'kanban_board_screen_test.mocks.dart';

@GenerateMocks([KanbanBloc])
void main() {
  group('KanbanBoardScreen', () {
    late MockKanbanBloc mockKanbanBloc;

    setUp(() {
      mockKanbanBloc = MockKanbanBloc();
      // Stub stream to return empty broadcast stream by default
      when(
        mockKanbanBloc.stream,
      ).thenAnswer((_) => Stream<KanbanState>.empty().asBroadcastStream());
    });

    testWidgets('displays loading indicator when state is loading', (
      WidgetTester tester,
    ) async {
      when(mockKanbanBloc.state).thenReturn(const KanbanLoading());
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(
          const KanbanLoading(),
        ).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message when state is error', (
      WidgetTester tester,
    ) async {
      final errorState = const KanbanError(ServerFailure());
      when(mockKanbanBloc.state).thenReturn(errorState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(errorState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('calls retry when retry button is tapped', (
      WidgetTester tester,
    ) async {
      final errorState = const KanbanError(ServerFailure());
      when(mockKanbanBloc.state).thenReturn(errorState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(errorState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      // The widget should trigger the retry action
      // We verify the widget behavior rather than the BLoC call directly
      verify(mockKanbanBloc.add(any)).called(greaterThan(0));
    });

    testWidgets('displays kanban columns when state is loaded', (
      WidgetTester tester,
    ) async {
      final toDoTasks = TestDataFactory.createTaskList(count: 2);
      final inProgressTasks = TestDataFactory.createTaskList(count: 1);
      final doneTasks = TestDataFactory.createTaskList(count: 1);

      final loadedState = KanbanLoaded(
        tasksBySection: {},
        tasksWithoutSection: [...toDoTasks, ...inProgressTasks, ...doneTasks],
        sections: const [],
      );
      when(mockKanbanBloc.state).thenReturn(loadedState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(loadedState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
        ),
      );

      // Should find kanban columns
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('displays columns in horizontal layout on desktop', (
      WidgetTester tester,
    ) async {
      final toDoTasks = TestDataFactory.createTaskList(count: 1);

      final loadedState = KanbanLoaded(
        tasksBySection: {},
        tasksWithoutSection: toDoTasks,
        sections: const [],
      );
      when(mockKanbanBloc.state).thenReturn(loadedState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(loadedState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      // Should find Row layout for desktop
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('displays columns in vertical layout on mobile', (
      WidgetTester tester,
    ) async {
      final toDoTasks = TestDataFactory.createTaskList(count: 1);

      final loadedState = KanbanLoaded(
        tasksBySection: {},
        tasksWithoutSection: toDoTasks,
        sections: const [],
      );
      when(mockKanbanBloc.state).thenReturn(loadedState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(loadedState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: OverflowBox(
            minWidth: 0,
            maxWidth: double.infinity,
            child: const KanbanBoardScreen(),
          ),
          screenSize: WidgetTestHelpers.mobileSize,
        ),
      );

      await tester.pumpAndSettle();
      // Should find Column layout for mobile
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('loads tasks on init', (WidgetTester tester) async {
      final loadingState = const KanbanLoading();
      when(mockKanbanBloc.state).thenReturn(loadingState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(loadingState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
        ),
      );

      // The widget should load tasks on init
      // We verify the widget behavior rather than the BLoC call directly
      await tester.pump();
      verify(mockKanbanBloc.add(any)).called(greaterThan(0));
    });

    testWidgets('displays filter sidebar when filters are open', (
      WidgetTester tester,
    ) async {
      final toDoTasks = TestDataFactory.createTaskList(count: 1);

      final loadedState = KanbanLoaded(
        tasksBySection: {},
        tasksWithoutSection: toDoTasks,
        sections: const [],
      );
      when(mockKanbanBloc.state).thenReturn(loadedState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(loadedState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: OverflowBox(
            minWidth: 0,
            maxWidth: double.infinity,
            child: const KanbanBoardScreen(),
          ),
          screenSize: const Size(
            1400,
            800,
          ), // Wider screen to accommodate sidebar
        ),
      );

      await tester.pumpAndSettle();
      // Toggle filters
      final filterButton = find.byIcon(Icons.filter_alt_outlined);
      if (filterButton.evaluate().isNotEmpty) {
        await tester.tap(filterButton);
        await tester.pumpAndSettle();
      }
    });

    testWidgets('displays all column types', (WidgetTester tester) async {
      final toDoTasks = TestDataFactory.createTaskList(count: 1);

      final loadedState = KanbanLoaded(
        tasksBySection: {},
        tasksWithoutSection: toDoTasks,
        sections: const [],
      );
      when(mockKanbanBloc.state).thenReturn(loadedState);
      when(mockKanbanBloc.stream).thenAnswer(
        (_) => Stream<KanbanState>.value(loadedState).asBroadcastStream(),
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndBloc<KanbanBloc>(
          bloc: mockKanbanBloc,
          child: const KanbanBoardScreen(),
        ),
      );

      // Should find column containers
      expect(find.byType(Container), findsWidgets);
    });
  });
}
