import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/network/connectivity_service.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import '../../../../mocks/mock_setup.dart';

import 'tasks_repository_impl_test.mocks.dart';

@GenerateMocks([
  TodoistApi,
  TasksLocalDataSource,
  ConnectivityService,
])
void main() {
  late TasksRepositoryImpl repository;
  late MockTodoistApi mockApi;
  late MockTasksLocalDataSource mockLocalDataSource;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    setupMockDummyValues();
    mockApi = MockTodoistApi();
    mockLocalDataSource = MockTasksLocalDataSource();
    mockConnectivityService = MockConnectivityService();
    repository = TasksRepositoryImpl(
      mockApi,
      mockLocalDataSource,
      mockConnectivityService,
    );
  });

  group('TasksRepositoryImpl - Online scenarios', () {
    test('should fetch tasks from API and cache when online', () async {
      final now = DateTime.now();
      final taskModel = TaskModel(
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

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockApi.getTasks()).thenAnswer((_) async => [taskModel]);
      when(mockLocalDataSource.cacheTasks([taskModel]))
          .thenAnswer((_) async => const Success<void>(null));
      
      // Track call count to return empty first, then cached data
      var callCount = 0;
      when(mockLocalDataSource.getCachedTasks()).thenAnswer((_) async {
        callCount++;
        if (callCount == 1) {
          // First call returns empty (no cache)
          return Success<List<Task>>([]);
        } else {
          // Second call returns cached data
          return Success([taskModel.toEntity()]);
        }
      });

      final result = await repository.getTasks();

      expect(result, isA<Success<List<Task>>>());
      verify(mockApi.getTasks()).called(1);
      verify(mockLocalDataSource.cacheTasks([taskModel])).called(1);
      // getCachedTasks is called twice: once at the start (empty), once at the end (cached)
      verify(mockLocalDataSource.getCachedTasks()).called(2);
    });

    test('should return cached data when API fails but cache exists', () async {
      final now = DateTime.now();
      final task = Task(
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
        content: 'Cached Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockApi.getTasks()).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        error: 'Network error',
      ));
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => Success([task]));

      final result = await repository.getTasks();

      expect(result, isA<Success<List<Task>>>());
      if (result is Success<List<Task>>) {
        expect(result.value.first.content, equals('Cached Task'));
      }
    });
  });

  group('TasksRepositoryImpl - Offline scenarios', () {
    test('should return cached data when offline', () async {
      final now = DateTime.now();
      final task = Task(
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
        content: 'Cached Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCachedTasks())
          .thenAnswer((_) async => Success([task]));

      final result = await repository.getTasks();

      expect(result, isA<Success<List<Task>>>());
      verifyNever(mockApi.getTasks());
      verify(mockLocalDataSource.getCachedTasks()).called(1);
    });

    test('should store task locally when creating offline', () async {
      final now = DateTime.now();
      final task = Task(
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
        content: 'New Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);
      when(mockLocalDataSource.storeTaskEntity(task, isSynced: false))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.createTask(task);

      expect(result, isA<Success<Task>>());
      verifyNever(mockApi.addTask(any));
      verify(mockLocalDataSource.storeTaskEntity(task, isSynced: false)).called(1);
    });
  });

  group('TasksRepositoryImpl - Sync', () {
    test('should sync pending changes when online', () async {
      final now = DateTime.now();
      final unsyncedTask = Task(
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
        content: 'Unsynced Task',
        description: '',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockLocalDataSource.getUnsyncedTasks())
          .thenAnswer((_) async => Success([unsyncedTask]));
      when(mockApi.updateTask(any, any)).thenAnswer((_) async => TaskModel(
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
            content: 'Unsynced Task',
            description: '',
            noteCount: 0,
            dayOrder: 0,
            isCollapsed: false,
          ));
      when(mockLocalDataSource.markTaskAsSynced('task1'))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.syncPendingChanges();

      expect(result, isA<Success<void>>());
      verify(mockLocalDataSource.getUnsyncedTasks()).called(1);
    });
  });
}

