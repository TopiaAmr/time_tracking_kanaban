import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/widgets/task_card.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_state.dart';
import '../../features/timer/presentation/widgets/timer_widget_test.mocks.dart';
import 'widget_test_helpers.dart';

void main() {
  group('TaskCard', () {
    late MockTimerBloc mockTimerBloc;

    setUp(() {
      mockTimerBloc = MockTimerBloc();
      when(mockTimerBloc.stream).thenAnswer((_) => const Stream<TimerState>.empty());
      when(mockTimerBloc.state).thenReturn(const TimerInitial());
    });

    testWidgets('displays task content', (WidgetTester tester) async {
      final task = TestDataFactory.createTask(
        content: 'Test Task Title',
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task),
        ),
      );

      expect(find.text('Test Task Title'), findsOneWidget);
    });

    testWidgets('displays task description when provided',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask(
        content: 'Test Task',
        description: 'Task description text',
      );

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task),
        ),
      );

      expect(find.text('Task description text'), findsOneWidget);
    });

    testWidgets('displays tags when provided', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();
      final tags = ['urgent', 'important', 'frontend'];

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task, tags: tags),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('important'), findsOneWidget);
      expect(find.text('frontend'), findsOneWidget);
    });

    testWidgets('displays assignees when provided',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask();
      final assignees = ['John', 'Jane'];

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: Scaffold(
            body: TaskCard(task: task, assignees: assignees),
          ),
        ),
      );

      // Check for avatar circles (assignees are displayed as avatars)
      // Note: There may be more CircleAvatars in the widget tree, so we check for at least 2
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(2));
    });

    testWidgets('displays due date when provided',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask();
      final dueDate = DateTime(2024, 1, 15);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task, dueDate: dueDate),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('displays comment count when greater than zero',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask(noteCount: 5);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task, commentCount: 5),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.comment_outlined), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('does not display comment count when zero',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask(noteCount: 0);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task, commentCount: 0),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.comment_outlined), findsNothing);
    });

    testWidgets('calls onTap when card is tapped',
        (WidgetTester tester) async {
      var tapped = false;
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(
            task: task,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Use find.first to get the first InkWell (the one with onTap callback)
      final inkWellFinder = find.descendant(
        of: find.byType(TaskCard),
        matching: find.byType(InkWell),
      );
      await tester.tap(inkWellFinder.first);
      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when card is long pressed',
        (WidgetTester tester) async {
      var longPressed = false;
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(
            task: task,
            onLongPress: () {
              longPressed = true;
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Use find.first to get the first InkWell (the one with onLongPress callback)
      final inkWellFinder = find.descendant(
        of: find.byType(TaskCard),
        matching: find.byType(InkWell),
      );
      await tester.longPress(inkWellFinder.first);
      expect(longPressed, isTrue);
    });

    testWidgets('adapts padding for mobile screen size',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task),
          screenSize: WidgetTestHelpers.mobileSize,
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('adapts padding for desktop screen size',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: TaskCard(task: task),
          screenSize: WidgetTestHelpers.desktopSize,
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.margin, const EdgeInsets.only(bottom: 12));
    });

    testWidgets('displays task with all optional fields',
        (WidgetTester tester) async {
      final task = TestDataFactory.createTask(
        content: 'Complete Task',
        description: 'Full description',
        labels: ['label1', 'label2'],
      );
      final dueDate = DateTime(2024, 1, 20);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialAppAndCommonProviders(
          timerBloc: mockTimerBloc,
          child: Scaffold(
            body: TaskCard(
              task: task,
              tags: ['label1', 'label2'],
              assignees: ['Alice', 'Bob'],
              dueDate: dueDate,
              commentCount: 3,
            ),
          ),
        ),
      );

      expect(find.text('Complete Task'), findsOneWidget);
      expect(find.text('Full description'), findsOneWidget);
      expect(find.text('label1'), findsOneWidget);
      expect(find.text('label2'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
      expect(find.byIcon(Icons.comment_outlined), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });
  });
}

