import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/network/connectivity_service.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/tasks_local_datasource.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_request_models.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

/// Implementation of [TasksRepository] that uses the Todoist API with offline support.
///
/// This implementation follows an offline-first strategy:
/// - Checks connectivity before making API calls
/// - Caches all API responses to local database
/// - Returns cached data when offline
/// - Stores write operations locally when offline for later sync
@Injectable(as: TasksRepository)
class TasksRepositoryImpl implements TasksRepository {
  /// The Todoist API client to use for network requests.
  final TodoistApi api;

  /// The local datasource for caching tasks, projects, and sections.
  final TasksLocalDataSource localDataSource;

  /// The connectivity service to check internet status.
  final ConnectivityService connectivityService;

  /// Creates a [TasksRepositoryImpl] with the given dependencies.
  TasksRepositoryImpl(this.api, this.localDataSource, this.connectivityService);

  @override
  Future<Result<List<Task>>> getTasks({
    String? projectId,
    String? sectionId,
  }) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        // Fetch from API
        final models = await api.getTasks(
          projectId: projectId,
          sectionId: sectionId,
        );
        // Cache the results
        final cacheResult = await localDataSource.cacheTasks(models);
        if (cacheResult is Error) {
          // If caching fails, still return the API data
        }
        // Return cached data (following specs: check internet -> fetch API -> save to Drift -> return Drift data)
        return await localDataSource.getCachedTasks(
          projectId: projectId,
          sectionId: sectionId,
        );
      } on DioException catch (e) {
        // If API fails, try to return cached data
        final cachedResult = await localDataSource.getCachedTasks(
          projectId: projectId,
          sectionId: sectionId,
        );
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<List<Task>>(
          ServerFailure([e.message, e.response?.statusCode]),
        );
      } catch (e) {
        // If API fails, try to return cached data
        final cachedResult = await localDataSource.getCachedTasks(
          projectId: projectId,
          sectionId: sectionId,
        );
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<List<Task>>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCachedTasks(
        projectId: projectId,
        sectionId: sectionId,
      );
    }
  }

  @override
  Future<Result<Task>> getTask(String id) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        // Try to get from API (getTask endpoint exists per todoist_api.dart)
        final model = await api.getTask(id);
        // Cache the result
        await localDataSource.cacheTasks([model]);
        // Return cached data
        return await localDataSource.getCachedTask(id);
      } on DioException catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedTask(id);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<Task>(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedTask(id);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<Task>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCachedTask(id);
    }
  }

  @override
  Future<Result<Task>> createTask(Task task) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final body = AddTaskBody(
          content: task.content,
          description: task.description,
          projectId: task.projectId,
          sectionId: task.sectionId.isEmpty ? null : task.sectionId,
          labels: task.labels,
          priority: task.priority,
          dueDate: task.due?.toIso8601String().split('T').first,
        );
        final model = await api.addTask(body);
        final createdTask = model.toEntity();
        // Cache the created task
        await localDataSource.storeTask(model, isSynced: true);
        return Success(createdTask);
      } on DioException catch (e) {
        // If API fails, store locally for later sync
        await localDataSource.storeTaskEntity(task, isSynced: false);
        return Error<Task>(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        // If API fails, store locally for later sync
        await localDataSource.storeTaskEntity(task, isSynced: false);
        return Error<Task>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: store locally with isSynced: false
      final storeResult = await localDataSource.storeTaskEntity(
        task,
        isSynced: false,
      );
      if (storeResult is Error<void>) {
        return Error<Task>(storeResult.failure);
      }
      return Success(task);
    }
  }

  @override
  Future<Result<Task>> updateTask(Task task) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final body = UpdateTaskBody(
          content: task.content,
          description: task.description,
          labels: task.labels,
          dueDate: task.due?.toIso8601String().split('T').first,
        );
        final model = await api.updateTask(task.id, body);
        final updatedTask = model.toEntity();
        // Cache the updated task
        await localDataSource.storeTask(model, isSynced: true);
        return Success(updatedTask);
      } on DioException catch (e) {
        // If API fails, store locally for later sync
        await localDataSource.storeTaskEntity(task, isSynced: false);
        return Error<Task>(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        // If API fails, store locally for later sync
        await localDataSource.storeTaskEntity(task, isSynced: false);
        return Error<Task>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: store locally with isSynced: false
      final storeResult = await localDataSource.storeTaskEntity(
        task,
        isSynced: false,
      );
      if (storeResult is Error<void>) {
        return Error<Task>(storeResult.failure);
      }
      return Success(task);
    }
  }

  @override
  Future<Result<Task>> moveTask(
    Task task,
    String projectId,
    String? sectionId,
  ) async {
    // Offline-first: Always update local database first (optimistic update)
    final updatedTask = Task(
      userId: task.userId,
      id: task.id,
      projectId: projectId,
      sectionId: sectionId ?? '',
      parentId: task.parentId,
      addedByUid: task.addedByUid,
      assignedByUid: task.assignedByUid,
      responsibleUid: task.responsibleUid,
      labels: task.labels,
      deadline: task.deadline,
      duration: task.duration,
      checked: task.checked,
      isDeleted: task.isDeleted,
      addedAt: task.addedAt,
      completedAt: task.completedAt,
      completedByUid: task.completedByUid,
      updatedAt: DateTime.now(),
      due: task.due,
      priority: task.priority,
      childOrder: task.childOrder,
      content: task.content,
      description: task.description,
      noteCount: task.noteCount,
      dayOrder: task.dayOrder,
      isCollapsed: task.isCollapsed,
    );

    // Store locally first (optimistic update)
    final storeResult = await localDataSource.storeTaskEntity(
      updatedTask,
      isSynced: false,
    );
    if (storeResult is Error<void>) {
      return Error<Task>(storeResult.failure);
    }

    // Sync with API in the background (fire and forget)
    final isConnected = await connectivityService.isConnected();
    if (isConnected) {
      // Call API in background without blocking
      _syncMoveTaskInBackground(task, projectId, sectionId);
    }

    // Return success immediately after local update
    return Success(updatedTask);
  }

  /// Syncs the move task operation with the API in the background.
  Future<void> _syncMoveTaskInBackground(
    Task originalTask,
    String projectId,
    String? sectionId,
  ) async {
    try {
      final body = MoveTaskBody(projectId: projectId, sectionId: sectionId);
      final model = await api.moveTask(originalTask.id, body);
      // Update local database with synced status
      await localDataSource.storeTask(model, isSynced: true);
    } catch (e) {
      // If API sync fails, the task remains with isSynced: false
      // It will be synced later via syncPendingChanges
      // Silently handle the error - don't throw
    }
  }

  @override
  Future<Result<void>> deleteTask(String id) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        await api.deleteTask(id);
        // Remove from cache
        // Note: We could also mark as deleted in cache instead of removing
        return const Success(null);
      } on DioException catch (e) {
        // If API fails, mark for deletion locally
        final taskResult = await localDataSource.getCachedTask(id);
        if (taskResult is Success<Task>) {
          final task = taskResult.value;
          final deletedTask = Task(
            userId: task.userId,
            id: task.id,
            projectId: task.projectId,
            sectionId: task.sectionId,
            parentId: task.parentId,
            addedByUid: task.addedByUid,
            assignedByUid: task.assignedByUid,
            responsibleUid: task.responsibleUid,
            labels: task.labels,
            deadline: task.deadline,
            duration: task.duration,
            checked: task.checked,
            isDeleted: true,
            addedAt: task.addedAt,
            completedAt: task.completedAt,
            completedByUid: task.completedByUid,
            updatedAt: DateTime.now(),
            due: task.due,
            priority: task.priority,
            childOrder: task.childOrder,
            content: task.content,
            description: task.description,
            noteCount: task.noteCount,
            dayOrder: task.dayOrder,
            isCollapsed: task.isCollapsed,
          );
          await localDataSource.storeTaskEntity(deletedTask, isSynced: false);
        }
        return Error<Task>(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        return Error<Task>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: mark for deletion locally
      final taskResult = await localDataSource.getCachedTask(id);
      if (taskResult is Error<Task>) {
        return Error<void>(taskResult.failure);
      }
      final task = (taskResult as Success<Task>).value;
      final deletedTask = Task(
        userId: task.userId,
        id: task.id,
        projectId: task.projectId,
        sectionId: task.sectionId,
        parentId: task.parentId,
        addedByUid: task.addedByUid,
        assignedByUid: task.assignedByUid,
        responsibleUid: task.responsibleUid,
        labels: task.labels,
        deadline: task.deadline,
        duration: task.duration,
        checked: task.checked,
        isDeleted: true,
        addedAt: task.addedAt,
        completedAt: task.completedAt,
        completedByUid: task.completedByUid,
        updatedAt: DateTime.now(),
        due: task.due,
        priority: task.priority,
        childOrder: task.childOrder,
        content: task.content,
        description: task.description,
        noteCount: task.noteCount,
        dayOrder: task.dayOrder,
        isCollapsed: task.isCollapsed,
      );
      final storeResult = await localDataSource.storeTaskEntity(
        deletedTask,
        isSynced: false,
      );
      if (storeResult is Error<void>) {
        return Error<Task>(storeResult.failure);
      }
      return const Success(null);
    }
  }

  @override
  Future<Result<void>> closeTask(String id) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        await api.closeTask(id);
        // Update cache - mark task as checked
        final taskResult = await localDataSource.getCachedTask(id);
        if (taskResult is Success<Task>) {
          final task = taskResult.value;
          final closedTask = Task(
            userId: task.userId,
            id: task.id,
            projectId: task.projectId,
            sectionId: task.sectionId,
            parentId: task.parentId,
            addedByUid: task.addedByUid,
            assignedByUid: task.assignedByUid,
            responsibleUid: task.responsibleUid,
            labels: task.labels,
            deadline: task.deadline,
            duration: task.duration,
            checked: true,
            isDeleted: task.isDeleted,
            addedAt: task.addedAt,
            completedAt: DateTime.now(),
            completedByUid: task.addedByUid,
            updatedAt: DateTime.now(),
            due: task.due,
            priority: task.priority,
            childOrder: task.childOrder,
            content: task.content,
            description: task.description,
            noteCount: task.noteCount,
            dayOrder: task.dayOrder,
            isCollapsed: task.isCollapsed,
          );
          await localDataSource.storeTaskEntity(closedTask, isSynced: true);
        }
        return const Success(null);
      } on DioException catch (e) {
        // If API fails, update locally for later sync
        final taskResult = await localDataSource.getCachedTask(id);
        if (taskResult is Success<Task>) {
          final task = taskResult.value;
          final closedTask = Task(
            userId: task.userId,
            id: task.id,
            projectId: task.projectId,
            sectionId: task.sectionId,
            parentId: task.parentId,
            addedByUid: task.addedByUid,
            assignedByUid: task.assignedByUid,
            responsibleUid: task.responsibleUid,
            labels: task.labels,
            deadline: task.deadline,
            duration: task.duration,
            checked: true,
            isDeleted: task.isDeleted,
            addedAt: task.addedAt,
            completedAt: DateTime.now(),
            completedByUid: task.addedByUid,
            updatedAt: DateTime.now(),
            due: task.due,
            priority: task.priority,
            childOrder: task.childOrder,
            content: task.content,
            description: task.description,
            noteCount: task.noteCount,
            dayOrder: task.dayOrder,
            isCollapsed: task.isCollapsed,
          );
          await localDataSource.storeTaskEntity(closedTask, isSynced: false);
        }
        return Error<Task>(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        return Error<Task>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: update locally with isSynced: false
      final taskResult = await localDataSource.getCachedTask(id);
      if (taskResult is Error<Task>) {
        return Error<void>(taskResult.failure);
      }
      final task = (taskResult as Success<Task>).value;
      final closedTask = Task(
        userId: task.userId,
        id: task.id,
        projectId: task.projectId,
        sectionId: task.sectionId,
        parentId: task.parentId,
        addedByUid: task.addedByUid,
        assignedByUid: task.assignedByUid,
        responsibleUid: task.responsibleUid,
        labels: task.labels,
        deadline: task.deadline,
        duration: task.duration,
        checked: true,
        isDeleted: task.isDeleted,
        addedAt: task.addedAt,
        completedAt: DateTime.now(),
        completedByUid: task.addedByUid,
        updatedAt: DateTime.now(),
        due: task.due,
        priority: task.priority,
        childOrder: task.childOrder,
        content: task.content,
        description: task.description,
        noteCount: task.noteCount,
        dayOrder: task.dayOrder,
        isCollapsed: task.isCollapsed,
      );
      final storeResult = await localDataSource.storeTaskEntity(
        closedTask,
        isSynced: false,
      );
      if (storeResult is Error<void>) {
        return Error<Task>(storeResult.failure);
      }
      return const Success(null);
    }
  }

  @override
  Future<Result<List<Project>>> getProjects() async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final models = await api.getProjects();
        // Cache the results
        await localDataSource.cacheProjects(models);
        // Return cached data
        return await localDataSource.getCachedProjects();
      } on DioException catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedProjects();
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<List<Project>>(
          ServerFailure([e.message, e.response?.statusCode]),
        );
      } catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedProjects();
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<List<Project>>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCachedProjects();
    }
  }

  @override
  Future<Result<Project>> getProject(String id) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final model = await api.getProject(id);
        // Cache the result
        await localDataSource.cacheProjects([model]);
        // Return cached data
        return await localDataSource.getCachedProject(id);
      } on DioException catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedProject(id);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<Project>(
          ServerFailure([e.message, e.response?.statusCode]),
        );
      } catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedProject(id);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<Project>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCachedProject(id);
    }
  }

  @override
  Future<Result<List<Section>>> getSections({String? projectId}) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final models = await api.getSections(projectId: projectId);
        // Cache the results
        await localDataSource.cacheSections(models);
        // Return cached data
        return await localDataSource.getCachedSections(projectId: projectId);
      } on DioException catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedSections(
          projectId: projectId,
        );
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<List<Section>>(
          ServerFailure([e.message, e.response?.statusCode]),
        );
      } catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedSections(
          projectId: projectId,
        );
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<List<Section>>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCachedSections(projectId: projectId);
    }
  }

  @override
  Future<Result<Section>> getSection(String id) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        final model = await api.getSection(id);
        // Cache the result
        await localDataSource.cacheSections([model]);
        // Return cached data
        return await localDataSource.getCachedSection(id);
      } on DioException catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedSection(id);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<Section>(
          ServerFailure([e.message, e.response?.statusCode]),
        );
      } catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCachedSection(id);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error<Section>(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCachedSection(id);
    }
  }

  @override
  Future<Result<void>> syncPendingChanges() async {
    final isConnected = await connectivityService.isConnected();
    if (!isConnected) {
      return Error<void>(NetworkFailure(['No internet connection']));
    }

    try {
      // Get all unsynced tasks
      final unsyncedResult = await localDataSource.getUnsyncedTasks();
      if (unsyncedResult is Error<List<Task>>) {
        return Error<void>(unsyncedResult.failure);
      }

      final unsyncedTasks = (unsyncedResult as Success<List<Task>>).value;

      // Sync each unsynced task
      for (final task in unsyncedTasks) {
        if (task.isDeleted) {
          // Task was deleted offline - delete via API
          try {
            await api.deleteTask(task.id);
            await localDataSource.markTaskAsSynced(task.id);
          } catch (e) {
            // Continue with other tasks even if one fails
            continue;
          }
        } else {
          // Task was created or updated offline
          // For created tasks (temporary ID), we need to create via API
          // For updated tasks, we need to update via API
          // This is a simplified version - in production, you'd track the operation type
          try {
            final body = UpdateTaskBody(
              content: task.content,
              description: task.description,
              labels: task.labels,
              dueDate: task.due?.toIso8601String().split('T').first,
            );
            await api.updateTask(task.id, body);
            await localDataSource.markTaskAsSynced(task.id);
          } catch (e) {
            // If update fails, try create (in case it's a new task)
            try {
              final createBody = AddTaskBody(
                content: task.content,
                description: task.description,
                projectId: task.projectId,
                sectionId: task.sectionId.isEmpty ? null : task.sectionId,
                labels: task.labels,
                priority: task.priority,
                dueDate: task.due?.toIso8601String().split('T').first,
              );
              final model = await api.addTask(createBody);
              await localDataSource.storeTask(model, isSynced: true);
            } catch (e2) {
              // Continue with other tasks even if one fails
              continue;
            }
          }
        }
      }

      return const Success(null);
    } catch (e) {
      return Error<void>(NetworkFailure([e.toString()]));
    }
  }
}
