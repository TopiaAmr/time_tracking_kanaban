import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/project_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/section_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

void main() {
  late AppDatabase database;
  late TasksLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase(LazyDatabase(() async => NativeDatabase.memory()));
    dataSource = TasksLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('TasksLocalDataSource', () {
    test('should cache and retrieve tasks', () async {
      final now = DateTime.now();
      final taskModel = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        addedByUid: 'user1',
        labels: ['label1'],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: 1,
        childOrder: 0,
        content: 'Test Task',
        description: 'Test Description',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      final cacheResult = await dataSource.cacheTasks([taskModel]);
      expect(cacheResult, isA<Success<void>>());

      final retrieveResult = await dataSource.getCachedTasks();
      expect(retrieveResult, isA<Success<List<Task>>>());
      if (retrieveResult is Success<List<Task>>) {
        expect(retrieveResult.value.length, equals(1));
        expect(retrieveResult.value.first.id, equals('task1'));
        expect(retrieveResult.value.first.content, equals('Test Task'));
      }
    });

    test('should filter tasks by projectId', () async {
      final now = DateTime.now();
      final task1 = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        addedByUid: 'user1',
        labels: [],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: 1,
        childOrder: 0,
        content: 'Task 1',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );
      final task2 = TaskModel(
        userId: 'user1',
        id: 'task2',
        projectId: 'project2',
        sectionId: 'section2',
        addedByUid: 'user1',
        labels: [],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: 1,
        childOrder: 0,
        content: 'Task 2',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      await dataSource.cacheTasks([task1, task2]);

      final result = await dataSource.getCachedTasks(projectId: 'project1');
      expect(result, isA<Success<List<Task>>>());
      if (result is Success<List<Task>>) {
        expect(result.value.length, equals(1));
        expect(result.value.first.id, equals('task1'));
      }
    });

    test('should cache and retrieve projects', () async {
      final now = DateTime.now();
      final projectModel = ProjectModel(
        id: 'project1',
        canAssignTasks: true,
        childOrder: 0,
        color: 'blue',
        creatorUid: 'user1',
        createdAt: now,
        isArchived: false,
        isDeleted: false,
        isFavorite: false,
        isFrozen: false,
        name: 'Test Project',
        updatedAt: now,
        viewStyle: 'list',
        defaultOrder: 0,
        description: 'Test Description',
        publicAccess: false,
        publicKey: 'key1',
        access: ProjectAccessModel(
          visibility: 'private',
          configuration: {},
        ),
        role: 'owner',
        inboxProject: false,
        isCollapsed: false,
        isShared: false,
      );

      final cacheResult = await dataSource.cacheProjects([projectModel]);
      expect(cacheResult, isA<Success<void>>());

      final retrieveResult = await dataSource.getCachedProjects();
      expect(retrieveResult, isA<Success<List<Project>>>());
      if (retrieveResult is Success<List<Project>>) {
        expect(retrieveResult.value.length, equals(1));
        expect(retrieveResult.value.first.id, equals('project1'));
        expect(retrieveResult.value.first.name, equals('Test Project'));
      }
    });

    test('should cache and retrieve sections', () async {
      final now = DateTime.now();
      final sectionModel = SectionModel(
        id: 'section1',
        userId: 'user1',
        projectId: 'project1',
        addedAt: now,
        updatedAt: now,
        name: 'Test Section',
        sectionOrder: 0,
        isArchived: false,
        isDeleted: false,
        isCollapsed: false,
      );

      final cacheResult = await dataSource.cacheSections([sectionModel]);
      expect(cacheResult, isA<Success<void>>());

      final retrieveResult = await dataSource.getCachedSections();
      expect(retrieveResult, isA<Success<List<Section>>>());
      if (retrieveResult is Success<List<Section>>) {
        expect(retrieveResult.value.length, equals(1));
        expect(retrieveResult.value.first.id, equals('section1'));
        expect(retrieveResult.value.first.name, equals('Test Section'));
      }
    });

    test('should get unsynced tasks', () async {
      final now = DateTime.now();
      final task = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        addedByUid: 'user1',
        labels: [],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: 1,
        childOrder: 0,
        content: 'Test Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      // Store task as unsynced
      await dataSource.storeTask(task, isSynced: false);

      final result = await dataSource.getUnsyncedTasks();
      expect(result, isA<Success<List<Task>>>());
      if (result is Success<List<Task>>) {
        expect(result.value.length, equals(1));
        expect(result.value.first.id, equals('task1'));
      }
    });

    test('should mark task as synced', () async {
      final now = DateTime.now();
      final task = TaskModel(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: 'section1',
        addedByUid: 'user1',
        labels: [],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: 1,
        childOrder: 0,
        content: 'Test Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      await dataSource.storeTask(task, isSynced: false);

      final markResult = await dataSource.markTaskAsSynced('task1');
      expect(markResult, isA<Success<void>>());

      final unsyncedResult = await dataSource.getUnsyncedTasks();
      if (unsyncedResult is Success<List<Task>>) {
        expect(unsyncedResult.value.length, equals(0));
      }
    });
  });
}

