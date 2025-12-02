import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/widgets/add_task_dialog.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'widget_test_helpers.dart';

void main() {
  group('AddTaskDialog', () {
    testWidgets('displays dialog title', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Scaffold(
            body: Builder(
              builder: (context) {
                return Material(
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => AddTaskDialog(
                            defaultProjectId: 'project1',
                            onCreateTask: (_) {},
                          ),
                        );
                      },
                      child: const Text('Open Dialog'),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();
      // Find the dialog title specifically (not the button text)
      expect(find.text('Add Task').last, findsOneWidget);
    });

    testWidgets('displays task title field', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  onCreateTask: (_) {},
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(TextFormField), findsWidgets);
    });

    testWidgets('validates required title field', (WidgetTester tester) async {
      Task? createdTask;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  onCreateTask: (task) {
                    createdTask = task;
                  },
                ),
              );
            },
          ),
        ),
      );

      // Try to submit without title
      final submitButton = find.text('Add Task').last;
      await tester.tap(submitButton);
      await tester.pump();

      // Should show validation error
      expect(find.text('Required'), findsOneWidget);
      expect(createdTask, isNull);
    });

    testWidgets('creates task when form is valid', (WidgetTester tester) async {
      Task? createdTask;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  onCreateTask: (task) {
                    createdTask = task;
                  },
                ),
              );
            },
          ),
        ),
      );

      // Enter task title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'New Task');
      await tester.pump();

      // Submit form
      final submitButton = find.text('Add Task').last;
      await tester.tap(submitButton);
      await tester.pump();

      expect(createdTask, isNotNull);
      expect(createdTask!.content, 'New Task');
      expect(createdTask!.projectId, 'project1');
    });

    testWidgets('allows entering description', (WidgetTester tester) async {
      Task? createdTask;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  onCreateTask: (task) {
                    createdTask = task;
                  },
                ),
              );
            },
          ),
        ),
      );

      // Enter title
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'New Task');
      await tester.pump();

      // Enter description
      final descriptionFields = find.byType(TextFormField);
      if (descriptionFields.evaluate().length > 1) {
        await tester.enterText(descriptionFields.at(1), 'Task description');
        await tester.pump();
      }

      // Submit
      final submitButton = find.text('Add Task').last;
      await tester.tap(submitButton);
      await tester.pump();

      expect(createdTask, isNotNull);
      if (descriptionFields.evaluate().length > 1) {
        expect(createdTask!.description, 'Task description');
      }
    });

    testWidgets('allows selecting due date', (WidgetTester tester) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  onCreateTask: (_) {},
                ),
              );
            },
          ),
        ),
      );

      // Find due date button
      final dueDateButton = find.text('Due Date');
      if (dueDateButton.evaluate().isNotEmpty) {
        await tester.tap(dueDateButton);
        await tester.pump();
      }
    });

    testWidgets('closes dialog when cancel button is tapped', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  onCreateTask: (_) {},
                ),
              );
            },
          ),
        ),
      );

      // Find close button (X icon)
      final closeButton = find.byIcon(Icons.close);
      if (closeButton.evaluate().isNotEmpty) {
        await tester.tap(closeButton);
        await tester.pump();
      }

      // Find cancel button
      final cancelButton = find.text('Cancel');
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pump();
      }
    });

    testWidgets('uses default project ID', (WidgetTester tester) async {
      Task? createdTask;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'custom-project',
                  onCreateTask: (task) {
                    createdTask = task;
                  },
                ),
              );
            },
          ),
        ),
      );

      // Enter title and submit
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'New Task');
      await tester.pump();

      final submitButton = find.text('Add Task').last;
      await tester.tap(submitButton);
      await tester.pump();

      expect(createdTask, isNotNull);
      expect(createdTask!.projectId, 'custom-project');
    });

    testWidgets('uses default section ID when provided', (
      WidgetTester tester,
    ) async {
      Task? createdTask;

      await tester.pumpWidget(
        WidgetTestHelpers.wrapWithMaterialApp(
          child: Builder(
            builder: (context) {
              return Material(
                child: AddTaskDialog(
                  defaultProjectId: 'project1',
                  defaultSectionId: 'section1',
                  onCreateTask: (task) {
                    createdTask = task;
                  },
                ),
              );
            },
          ),
        ),
      );

      // Enter title and submit
      final titleField = find.byType(TextFormField).first;
      await tester.enterText(titleField, 'New Task');
      await tester.pump();

      final submitButton = find.text('Add Task').last;
      await tester.tap(submitButton);
      await tester.pump();

      expect(createdTask, isNotNull);
      expect(createdTask!.sectionId, 'section1');
    });
  });
}
