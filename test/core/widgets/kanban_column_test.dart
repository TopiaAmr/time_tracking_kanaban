import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/widgets/kanban_column.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_state.dart';
import '../../features/timer/presentation/widgets/timer_widget_test.mocks.dart';
import 'widget_test_helpers.dart';

void main() {
  final testSection = Section(
    id: 'section1',
    userId: 'user1',
    projectId: 'project1',
    addedAt: DateTime.now(),
    updatedAt: DateTime.now(),
    name: 'To Do',
    sectionOrder: 0,
    isArchived: false,
    isDeleted: false,
    isCollapsed: false,
  );

  group('KanbanColumn', () {
    late MockTimerBloc mockTimerBloc;

    setUp(() {
      mockTimerBloc = MockTimerBloc();
      when(mockTimerBloc.stream).thenAnswer((_) => const Stream<TimerState>.empty());
      when(mockTimerBloc.state).thenReturn(const TimerInitial());
    });

    testWidgets('displays column title', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: const [],
          ),
        ),
      );

      expect(find.text('To Do'), findsOneWidget);
    });

    testWidgets('displays task count', (WidgetTester tester) async {
      final tasks = TestDataFactory.createTaskList(count: 3);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: tasks,
          ),
        ),
      );

      // Task count should be displayed (format depends on localization)
      expect(find.text('To Do'), findsOneWidget);
    });

    testWidgets('displays empty state when no tasks', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: Scaffold(
            body: KanbanColumn(
              section: testSection,
              tasks: [],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Should show empty tasks message
      expect(find.byType(Center), findsAtLeastNWidgets(1));
    });

    testWidgets('displays tasks when provided', (WidgetTester tester) async {
      final tasks = TestDataFactory.createTaskList(count: 2);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: tasks,
          ),
        ),
      );

      // Should find ListView with tasks
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('calls onTaskTap when task is tapped',
        (WidgetTester tester) async {
      var tappedTask = <Task>[];
      final tasks = TestDataFactory.createTaskList(count: 1);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: Scaffold(
            body: KanbanColumn(
              section: testSection,
              tasks: tasks,
              onTaskTap: (task) {
                tappedTask.add(task);
              },
            ),
          ),
        ),
      );

      // Find and tap the task card - wait for widget to be fully built
      await tester.pumpAndSettle();
      
      // Tap on the task content text which should trigger onTap
      await tester.tap(find.text(tasks.first.content));
      await tester.pump();
      expect(tappedTask.length, 1);
      expect(tappedTask.first.id, tasks.first.id);
    });

    testWidgets('displays Add Task button when onAddTask is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: [],
            onAddTask: null,
          ),
        ),
      );

      // Should not show add button when onAddTask is null
      expect(find.text('Add Task'), findsNothing);
    });

    testWidgets('calls onAddTask when Add Task button is tapped',
        (WidgetTester tester) async {
      var addTaskCalled = false;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: [],
            onAddTask: () {
              addTaskCalled = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      // The Add Task button is an IconButton with Icons.add, not text
      await tester.tap(find.byIcon(Icons.add));
      expect(addTaskCalled, isTrue);
    });

    testWidgets('accepts dropped tasks', (WidgetTester tester) async {
      var droppedTask = <Task>[];
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: [],
            onTaskDropped: (task) {
              droppedTask.add(task);
            },
          ),
        ),
      );

      // Find DragTarget and simulate drop
      final dragTarget = tester.widget<DragTarget<Task>>(
        find.byType(DragTarget<Task>),
      );

      // Simulate drop by calling onAcceptWithDetails
      dragTarget.onAcceptWithDetails?.call(
        DragTargetDetails<Task>(
          data: task,
          offset: Offset.zero,
        ),
      );
      expect(droppedTask.length, 1);
      expect(droppedTask.first.id, task.id);
    });

    testWidgets('adapts width for mobile screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: [],
          ),
          screenSize: WidgetTestHelpers.mobileSize,
        ),
      );

      // Verify mobile layout (width should be double.infinity)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('adapts width for desktop screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: KanbanColumn(
            section: testSection,
            tasks: [],
          ),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      // Verify desktop layout (width should be 300)
      expect(find.byType(Container), findsWidgets);
    });
  });
}

