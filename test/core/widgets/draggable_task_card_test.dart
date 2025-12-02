import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/widgets/draggable_task_card.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'widget_test_helpers.dart';

void main() {
  group('DraggableTaskCard', () {
    testWidgets('displays task card', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(
            body: DraggableTaskCard(task: task),
          ),
        ),
      );

      await tester.pumpAndSettle();
      // Should find the task card - LongPressDraggable with Task type
      expect(find.byType(LongPressDraggable<Task>), findsOneWidget);
    });

    testWidgets('displays task content', (WidgetTester tester) async {
      final task = TestDataFactory.createTask(content: 'Draggable Task');

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(task: task),
        ),
      );

      expect(find.text('Draggable Task'), findsOneWidget);
    });

    testWidgets('calls onTap when card is tapped', (WidgetTester tester) async {
      var tapped = false;
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(
            task: task,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('provides task data for drag', (WidgetTester tester) async {
      final task = TestDataFactory.createTask(id: 'task123');

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(task: task),
        ),
      );

      final draggable = tester.widget<LongPressDraggable<Task>>(
        find.byType(LongPressDraggable<Task>),
      );

      expect(draggable.data?.id, 'task123');
    });

    testWidgets('shows drag feedback when dragging', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(task: task),
        ),
      );

      final draggable = tester.widget<LongPressDraggable<Task>>(
        find.byType(LongPressDraggable<Task>),
      );

      // Verify feedback widget exists
      expect(draggable.feedback, isNotNull);
    });

    testWidgets('shows childWhenDragging when dragging', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(task: task),
        ),
      );

      final draggable = tester.widget<LongPressDraggable<Task>>(
        find.byType(LongPressDraggable<Task>),
      );

      // Verify childWhenDragging widget exists
      expect(draggable.childWhenDragging, isNotNull);
    });

    testWidgets('passes tags to task card', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();
      final tags = ['urgent', 'important'];

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(
            task: task,
            tags: tags,
          ),
        ),
      );

      expect(find.text('urgent'), findsOneWidget);
      expect(find.text('important'), findsOneWidget);
    });

    testWidgets('passes assignees to task card', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();
      final assignees = ['Alice', 'Bob'];

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(
            body: DraggableTaskCard(
              task: task,
              assignees: assignees,
            ),
          ),
        ),
      );

      // Note: There may be more CircleAvatars in the widget tree, so we check for at least 2
      expect(find.byType(CircleAvatar), findsAtLeastNWidgets(2));
    });

    testWidgets('passes due date to task card', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();
      final dueDate = DateTime(2024, 1, 20);

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(
            task: task,
            dueDate: dueDate,
          ),
        ),
      );

      expect(find.byIcon(Icons.calendar_today), findsOneWidget);
    });

    testWidgets('passes comment count to task card', (WidgetTester tester) async {
      final task = TestDataFactory.createTask();

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: DraggableTaskCard(
            task: task,
            commentCount: 5,
          ),
        ),
      );

      expect(find.byIcon(Icons.comment_outlined), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });
  });
}

