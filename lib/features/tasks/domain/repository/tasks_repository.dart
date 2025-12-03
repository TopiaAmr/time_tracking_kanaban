import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Abstraction over task, project, and section operations.
///
/// This repository interface defines all operations related to tasks,
/// projects, and sections. Infrastructure implementations are responsible
/// for fetching data from the Todoist API and managing local storage.
abstract class TasksRepository {
  /// Retrieves tasks, optionally filtered by [projectId] and/or [sectionId].
  ///
  /// If both [projectId] and [sectionId] are provided, returns tasks
  /// that match both criteria. If neither is provided, returns all tasks.
  /// If [forceRefresh] is true, fetches from API and updates local cache.
  Future<Result<List<Task>>> getTasks({
    String? projectId,
    String? sectionId,
    bool forceRefresh = false,
  });

  /// Retrieves a single task by its [id].
  Future<Result<Task>> getTask(String id);

  /// Creates a new task.
  ///
  /// The [task] parameter should contain all necessary task information.
  /// Returns the created task with its assigned ID.
  Future<Result<Task>> createTask(Task task);

  /// Updates an existing task.
  ///
  /// The [task] parameter should contain the updated task information.
  /// Returns the updated task.
  Future<Result<Task>> updateTask(Task task);

  /// Moves a task to a different project and/or section.
  ///
  /// The [task] is the task to move, [projectId] is the target project,
  /// and [sectionId] is the target section (null for tasks without section).
  Future<Result<Task>> moveTask(Task task, String projectId, String? sectionId);

  /// Deletes a task by its [id].
  ///
  /// This operation is permanent and cannot be undone.
  Future<Result<void>> deleteTask(String id);

  /// Closes (completes) a task by its [id].
  ///
  /// This marks the task as completed in the system.
  Future<Result<void>> closeTask(String id);

  /// Retrieves all projects accessible to the current user.
  Future<Result<List<Project>>> getProjects();

  /// Retrieves a single project by its [id].
  Future<Result<Project>> getProject(String id);

  /// Retrieves sections, optionally filtered by [projectId].
  ///
  /// If [projectId] is provided, returns only sections for that project.
  /// If not provided, returns all sections.
  /// If [forceRefresh] is true, fetches from API and updates local cache.
  Future<Result<List<Section>>> getSections({
    String? projectId,
    bool forceRefresh = false,
  });

  /// Retrieves a single section by its [id].
  Future<Result<Section>> getSection(String id);

  /// Syncs pending changes (tasks created/updated/deleted offline) with the API.
  ///
  /// This method should be called when connectivity is restored to sync
  /// any local changes that were made while offline.
  Future<Result<void>> syncPendingChanges();
}
