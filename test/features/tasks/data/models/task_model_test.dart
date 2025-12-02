import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

void main() {
  group('TaskModel', () {
    final now = DateTime.now();
    final taskModelJson = {
      'user_id': 'user1',
      'id': 'task1',
      'project_id': 'project1',
      'section_id': 'section1',
      'parent_id': null,
      'added_by_uid': 'user1',
      'assigned_by_uid': null,
      'responsible_uid': null,
      'labels': ['label1', 'label2'],
      'deadline': null,
      'duration': null,
      'checked': false,
      'is_deleted': false,
      'added_at': now.toIso8601String(),
      'completed_at': null,
      'completed_by_uid': null,
      'updated_at': now.toIso8601String(),
      'due_date': null,
      'priority': 1,
      'child_order': 0,
      'content': 'Test Task',
      'description': 'Test Description',
      'note_count': 0,
      'day_order': 0,
      'is_collapsed': false,
    };

    test('should create TaskModel from JSON', () {
      final model = TaskModel.fromJson(taskModelJson);

      expect(model.userId, 'user1');
      expect(model.id, 'task1');
      expect(model.projectId, 'project1');
      expect(model.sectionId, 'section1');
      expect(model.parentId, isNull);
      expect(model.addedByUid, 'user1');
      expect(model.labels, ['label1', 'label2']);
      expect(model.checked, false);
      expect(model.isDeleted, false);
      expect(model.content, 'Test Task');
      expect(model.description, 'Test Description');
      expect(model.priority, 1);
    });

    test('should convert TaskModel to JSON', () {
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: ['label1'],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: null,
        priority: 1,
        childOrder: 0,
        content: 'Test Task',
        description: 'Test Description',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final json = model.toJson();

      expect(json['user_id'], 'user1');
      expect(json['id'], 'task1');
      expect(json['project_id'], 'project1');
      expect(json['section_id'], 'section1');
      expect(json['content'], 'Test Task');
      expect(json['description'], 'Test Description');
    });

    test('should convert TaskModel to Task entity', () {
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: ['label1'],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: null,
        priority: 1,
        childOrder: 0,
        content: 'Test Task',
        description: 'Test Description',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();

      expect(entity, isA<Task>());
      expect(entity.userId, 'user1');
      expect(entity.id, 'task1');
      expect(entity.projectId, 'project1');
      expect(entity.sectionId, 'section1');
      expect(entity.content, 'Test Task');
      expect(entity.description, 'Test Description');
      expect(entity.priority, 1);
    });

    test('should handle null sectionId by converting to empty string', () {
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: null,
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: [],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: null,
        priority: 1,
        childOrder: 0,
        content: 'Test Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.sectionId, '');
    });

    test('should handle completed task with completedAt', () {
      final completedAt = DateTime.now();
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: [],
        deadline: null,
        duration: null,
        checked: true,
        isDeleted: false,
        addedAt: now,
        completedAt: completedAt,
        completedByUid: 'user1',
        updatedAt: now,
        due: null,
        priority: 1,
        childOrder: 0,
        content: 'Completed Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.checked, true);
      expect(entity.completedAt, completedAt);
      expect(entity.completedByUid, 'user1');
    });

    test('should handle task with due date', () {
      final dueDate = DateTime.now().add(const Duration(days: 1));
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: [],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: dueDate,
        priority: 1,
        childOrder: 0,
        content: 'Task with Due Date',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.due, dueDate);
    });

    test('should handle task with parent (subtask)', () {
      final model = TaskModel(
        userId: 'user1',
        id: 'task2',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: 'task1',
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: [],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: null,
        priority: 1,
        childOrder: 0,
        content: 'Subtask',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.parentId, 'task1');
    });

    test('should handle empty labels list', () {
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: [],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: null,
        priority: 1,
        childOrder: 0,
        content: 'Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.labels, isEmpty);
    });

    test('should handle high priority task', () {
      final model = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        parentId: null,
        addedByUid: 'user1',
        assignedByUid: null,
        responsibleUid: null,
        labels: [],
        deadline: null,
        duration: null,
        checked: false,
        isDeleted: false,
        addedAt: now,
        completedAt: null,
        completedByUid: null,
        updatedAt: now,
        due: null,
        priority: 4,
        childOrder: 0,
        content: 'High Priority Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final entity = model.toEntity();
      expect(entity.priority, 4);
    });
  });
}

