import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';

void main() {
  group('AddTaskBody', () {
    test('should create AddTaskBody from JSON', () {
      final json = {
        'content': 'New Task',
        'description': 'Task Description',
        'project_id': 'project1',
        'section_id': 'section1',
        'labels': ['label1', 'label2'],
        'priority': 2,
        'due_date': '2025-12-31',
        'due_lang': 'en',
      };

      final body = AddTaskBody.fromJson(json);

      expect(body.content, 'New Task');
      expect(body.description, 'Task Description');
      expect(body.projectId, 'project1');
      expect(body.sectionId, 'section1');
      expect(body.labels, ['label1', 'label2']);
      expect(body.priority, 2);
      expect(body.dueDate, '2025-12-31');
      expect(body.dueLang, 'en');
    });

    test('should convert AddTaskBody to JSON', () {
      final body = AddTaskBody(
        content: 'New Task',
        description: 'Task Description',
        projectId: 'project1',
        sectionId: 'section1',
        labels: ['label1', 'label2'],
        priority: 2,
        dueDate: '2025-12-31',
        dueLang: 'en',
      );

      final json = body.toJson();

      expect(json['content'], 'New Task');
      expect(json['description'], 'Task Description');
      expect(json['project_id'], 'project1');
      expect(json['section_id'], 'section1');
      expect(json['labels'], ['label1', 'label2']);
      expect(json['priority'], 2);
      expect(json['due_date'], '2025-12-31');
      expect(json['due_lang'], 'en');
    });

    test('should handle AddTaskBody with minimal fields', () {
      final body = AddTaskBody(
        content: 'Minimal Task',
        description: null,
        projectId: null,
        sectionId: null,
        labels: null,
        priority: null,
        dueDate: null,
        dueLang: null,
      );

      final json = body.toJson();

      expect(json['content'], 'Minimal Task');
      expect(json['description'], isNull);
      expect(json['project_id'], isNull);
      expect(json['section_id'], isNull);
      expect(json['labels'], isNull);
      expect(json['priority'], isNull);
      expect(json['due_date'], isNull);
      expect(json['due_lang'], isNull);
    });

    test('should handle AddTaskBody with only content', () {
      final body = AddTaskBody(content: 'Simple Task');

      final json = body.toJson();
      expect(json['content'], 'Simple Task');
      // Note: Freezed includes all fields in toJson, even if null
    });

    test('should handle AddTaskBody with empty labels', () {
      final body = AddTaskBody(
        content: 'Task with Empty Labels',
        labels: [],
      );

      final json = body.toJson();
      expect(json['labels'], isEmpty);
    });

    test('should handle AddTaskBody with high priority', () {
      final body = AddTaskBody(
        content: 'High Priority Task',
        priority: 4,
      );

      final json = body.toJson();
      expect(json['priority'], 4);
    });
  });

  group('MoveTaskBody', () {
    test('should create MoveTaskBody from JSON', () {
      final json = {
        'project_id': 'project2',
        'section_id': 'section2',
      };

      final body = MoveTaskBody.fromJson(json);

      expect(body.projectId, 'project2');
      expect(body.sectionId, 'section2');
    });

    test('should convert MoveTaskBody to JSON', () {
      final body = MoveTaskBody(
        projectId: 'project2',
        sectionId: 'section2',
      );

      final json = body.toJson();

      expect(json['project_id'], 'project2');
      expect(json['section_id'], 'section2');
    });

    test('should handle MoveTaskBody with only projectId', () {
      final body = MoveTaskBody(
        projectId: 'project2',
        sectionId: null,
      );

      final json = body.toJson();
      expect(json['project_id'], 'project2');
      expect(json['section_id'], isNull);
    });

    test('should handle MoveTaskBody with only sectionId', () {
      final body = MoveTaskBody(
        projectId: null,
        sectionId: 'section2',
      );

      final json = body.toJson();
      expect(json['project_id'], isNull);
      expect(json['section_id'], 'section2');
    });

    test('should handle MoveTaskBody with both null', () {
      final body = MoveTaskBody(
        projectId: null,
        sectionId: null,
      );

      final json = body.toJson();
      expect(json['project_id'], isNull);
      expect(json['section_id'], isNull);
    });
  });

  group('UpdateTaskBody', () {
    test('should create UpdateTaskBody from JSON', () {
      final json = {
        'content': 'Updated Task',
        'description': 'Updated Description',
        'labels': ['label3'],
        'due_date': '2026-01-01',
      };

      final body = UpdateTaskBody.fromJson(json);

      expect(body.content, 'Updated Task');
      expect(body.description, 'Updated Description');
      expect(body.labels, ['label3']);
      expect(body.dueDate, '2026-01-01');
    });

    test('should convert UpdateTaskBody to JSON', () {
      final body = UpdateTaskBody(
        content: 'Updated Task',
        description: 'Updated Description',
        labels: ['label3'],
        dueDate: '2026-01-01',
      );

      final json = body.toJson();

      expect(json['content'], 'Updated Task');
      expect(json['description'], 'Updated Description');
      expect(json['labels'], ['label3']);
      expect(json['due_date'], '2026-01-01');
    });

    test('should handle UpdateTaskBody with only content', () {
      final body = UpdateTaskBody(
        content: 'Updated Content',
        description: null,
        labels: null,
        dueDate: null,
      );

      final json = body.toJson();
      expect(json['content'], 'Updated Content');
      expect(json['description'], isNull);
      expect(json['labels'], isNull);
      expect(json['due_date'], isNull);
    });

    test('should handle UpdateTaskBody with only description', () {
      final body = UpdateTaskBody(
        content: null,
        description: 'Updated Description',
        labels: null,
        dueDate: null,
      );

      final json = body.toJson();
      expect(json['content'], isNull);
      expect(json['description'], 'Updated Description');
    });

    test('should handle UpdateTaskBody with only labels', () {
      final body = UpdateTaskBody(
        content: null,
        description: null,
        labels: ['new_label'],
        dueDate: null,
      );

      final json = body.toJson();
      expect(json['labels'], ['new_label']);
    });

    test('should handle UpdateTaskBody with only dueDate', () {
      final body = UpdateTaskBody(
        content: null,
        description: null,
        labels: null,
        dueDate: '2026-01-01',
      );

      final json = body.toJson();
      expect(json['due_date'], '2026-01-01');
    });

    test('should handle UpdateTaskBody with empty labels', () {
      final body = UpdateTaskBody(
        content: null,
        description: null,
        labels: [],
        dueDate: null,
      );

      final json = body.toJson();
      expect(json['labels'], isEmpty);
    });

    test('should handle UpdateTaskBody with all null', () {
      final body = UpdateTaskBody(
        content: null,
        description: null,
        labels: null,
        dueDate: null,
      );

      final json = body.toJson();
      expect(json['content'], isNull);
      expect(json['description'], isNull);
      expect(json['labels'], isNull);
      expect(json['due_date'], isNull);
    });
  });
}

