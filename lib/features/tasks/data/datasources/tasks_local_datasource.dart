import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/project_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/section_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/task_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Local datasource for caching tasks, projects, and sections.
///
/// This datasource handles all local database operations for tasks-related data,
/// including caching API responses and retrieving cached data for offline use.
@injectable
class TasksLocalDataSource {
  final AppDatabase _db;

  TasksLocalDataSource(this._db);

  /// Stores a Task entity directly in the database with optional sync status.
  Future<Result<void>> storeTaskEntity(
    Task task, {
    bool isSynced = false,
  }) async {
    try {
      await _db.into(_db.tasksTable).insert(
            TasksTableCompanion(
              userId: Value(task.userId),
              id: Value(task.id),
              projectId: Value(task.projectId),
              sectionId: Value(task.sectionId.isEmpty ? null : task.sectionId),
              parentId: Value(task.parentId),
              addedByUid: Value(task.addedByUid),
              assignedByUid: Value(task.assignedByUid),
              responsibleUid: Value(task.responsibleUid),
              labels: Value(task.labels),
              deadline: Value(task.deadline),
              duration: Value(task.duration),
              checked: Value(task.checked),
              isDeleted: Value(task.isDeleted),
              addedAt: Value(task.addedAt),
              completedAt: Value(task.completedAt),
              completedByUid: Value(task.completedByUid),
              updatedAt: Value(task.updatedAt),
              due: Value(task.due),
              priority: Value(task.priority),
              childOrder: Value(task.childOrder),
              content: Value(task.content),
              description: Value(task.description),
              noteCount: Value(task.noteCount),
              dayOrder: Value(task.dayOrder),
              isCollapsed: Value(task.isCollapsed),
              isSynced: Value(isSynced),
              lastSyncedAt: isSynced ? Value(DateTime.now()) : const Value.absent(),
            ),
            mode: InsertMode.replace,
          );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Stores a single task in the database with optional sync status.
  Future<Result<void>> storeTask(
    TaskModel task, {
    bool isSynced = true,
  }) async {
    try {
      await _db.into(_db.tasksTable).insert(
            TasksTableCompanion(
              userId: Value(task.userId),
              id: Value(task.id),
              projectId: Value(task.projectId),
              sectionId: Value(task.sectionId),
              parentId: Value(task.parentId),
              addedByUid: Value(task.addedByUid),
              assignedByUid: Value(task.assignedByUid),
              responsibleUid: Value(task.responsibleUid),
              labels: Value(task.labels),
              deadline: Value(task.deadline),
              duration: Value(task.duration),
              checked: Value(task.checked),
              isDeleted: Value(task.isDeleted),
              addedAt: Value(task.addedAt),
              completedAt: Value(task.completedAt),
              completedByUid: Value(task.completedByUid),
              updatedAt: Value(task.updatedAt),
              due: Value(task.due),
              priority: Value(task.priority),
              childOrder: Value(task.childOrder),
              content: Value(task.content),
              description: Value(task.description),
              noteCount: Value(task.noteCount),
              dayOrder: Value(task.dayOrder),
              isCollapsed: Value(task.isCollapsed),
              isSynced: Value(isSynced),
              lastSyncedAt: isSynced ? Value(DateTime.now()) : const Value.absent(),
            ),
            mode: InsertMode.replace,
          );
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Caches a list of tasks in the database.
  Future<Result<void>> cacheTasks(List<TaskModel> tasks) async {
    try {
      await _db.batch((batch) {
        for (final task in tasks) {
          batch.insert(
            _db.tasksTable,
            TasksTableCompanion(
              userId: Value(task.userId),
              id: Value(task.id),
              projectId: Value(task.projectId),
              sectionId: Value(task.sectionId),
              parentId: Value(task.parentId),
              addedByUid: Value(task.addedByUid),
              assignedByUid: Value(task.assignedByUid),
              responsibleUid: Value(task.responsibleUid),
              labels: Value(task.labels),
              deadline: Value(task.deadline),
              duration: Value(task.duration),
              checked: Value(task.checked),
              isDeleted: Value(task.isDeleted),
              addedAt: Value(task.addedAt),
              completedAt: Value(task.completedAt),
              completedByUid: Value(task.completedByUid),
              updatedAt: Value(task.updatedAt),
              due: Value(task.due),
              priority: Value(task.priority),
              childOrder: Value(task.childOrder),
              content: Value(task.content),
              description: Value(task.description),
              noteCount: Value(task.noteCount),
              dayOrder: Value(task.dayOrder),
              isCollapsed: Value(task.isCollapsed),
              isSynced: const Value(true),
              lastSyncedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.replace,
          );
        }
      });
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves cached tasks, optionally filtered by projectId and/or sectionId.
  Future<Result<List<Task>>> getCachedTasks({
    String? projectId,
    String? sectionId,
  }) async {
    try {
      var query = _db.select(_db.tasksTable)
        ..where((tbl) => tbl.isDeleted.equals(false));

      if (projectId != null) {
        query = query..where((tbl) => tbl.projectId.equals(projectId));
      }
      if (sectionId != null) {
        query = query..where((tbl) => tbl.sectionId.equals(sectionId));
      }

      final rows = await query.get();
      final tasks = rows.map((row) => _taskRowToEntity(row)).toList();
      return Success(tasks);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves a single cached task by ID.
  Future<Result<Task>> getCachedTask(String id) async {
    try {
      final query = _db.select(_db.tasksTable)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      if (row == null) {
        return Error(CacheFailure(['Task not found']));
      }
      return Success(_taskRowToEntity(row));
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Caches a list of projects in the database.
  Future<Result<void>> cacheProjects(List<ProjectModel> projects) async {
    try {
      await _db.batch((batch) {
        for (final project in projects) {
          batch.insert(
            _db.projectsTable,
            ProjectsTableCompanion(
              id: Value(project.id),
              canAssignTasks: Value(project.canAssignTasks),
              childOrder: Value(project.childOrder),
              color: Value(project.color),
              creatorUid: Value(project.creatorUid),
              createdAt: Value(project.createdAt),
              isArchived: Value(project.isArchived),
              isDeleted: Value(project.isDeleted),
              isFavorite: Value(project.isFavorite),
              isFrozen: Value(project.isFrozen),
              name: Value(project.name),
              updatedAt: Value(project.updatedAt),
              viewStyle: Value(project.viewStyle),
              defaultOrder: Value(project.defaultOrder),
              description: Value(project.description),
              publicAccess: Value(project.publicAccess),
              publicKey: Value(project.publicKey),
              accessVisibility: Value(project.access.visibility),
              accessConfiguration: Value(project.access.configuration),
              role: Value(project.role),
              parentId: Value(project.parentId),
              inboxProject: Value(project.inboxProject),
              isCollapsed: Value(project.isCollapsed),
              isShared: Value(project.isShared),
              lastSyncedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.replace,
          );
        }
      });
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves all cached projects.
  Future<Result<List<Project>>> getCachedProjects() async {
    try {
      final query = _db.select(_db.projectsTable)
        ..where((tbl) => tbl.isDeleted.equals(false));
      final rows = await query.get();
      final projects = rows.map((row) => _projectRowToEntity(row)).toList();
      return Success(projects);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves a single cached project by ID.
  Future<Result<Project>> getCachedProject(String id) async {
    try {
      final query = _db.select(_db.projectsTable)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      if (row == null) {
        return Error(CacheFailure(['Project not found']));
      }
      return Success(_projectRowToEntity(row));
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Caches a list of sections in the database.
  Future<Result<void>> cacheSections(List<SectionModel> sections) async {
    try {
      await _db.batch((batch) {
        for (final section in sections) {
          batch.insert(
            _db.sectionsTable,
            SectionsTableCompanion(
              id: Value(section.id),
              userId: Value(section.userId),
              projectId: Value(section.projectId),
              addedAt: Value(section.addedAt),
              updatedAt: Value(section.updatedAt),
              archivedAt: Value(section.archivedAt),
              name: Value(section.name),
              sectionOrder: Value(section.sectionOrder),
              isArchived: Value(section.isArchived),
              isDeleted: Value(section.isDeleted),
              isCollapsed: Value(section.isCollapsed),
              lastSyncedAt: Value(DateTime.now()),
            ),
            mode: InsertMode.replace,
          );
        }
      });
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves cached sections, optionally filtered by projectId.
  Future<Result<List<Section>>> getCachedSections({String? projectId}) async {
    try {
      var query = _db.select(_db.sectionsTable)
        ..where((tbl) => tbl.isDeleted.equals(false));

      if (projectId != null) {
        query = query..where((tbl) => tbl.projectId.equals(projectId));
      }

      final rows = await query.get();
      final sections = rows.map((row) => _sectionRowToEntity(row)).toList();
      return Success(sections);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves a single cached section by ID.
  Future<Result<Section>> getCachedSection(String id) async {
    try {
      final query = _db.select(_db.sectionsTable)
        ..where((tbl) => tbl.id.equals(id));
      final row = await query.getSingleOrNull();
      if (row == null) {
        return Error(CacheFailure(['Section not found']));
      }
      return Success(_sectionRowToEntity(row));
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Gets all unsynced tasks (tasks that were created/updated/deleted offline).
  Future<Result<List<Task>>> getUnsyncedTasks() async {
    try {
      final query = _db.select(_db.tasksTable)
        ..where((tbl) => tbl.isSynced.equals(false));
      final rows = await query.get();
      final tasks = rows.map((row) => _taskRowToEntity(row)).toList();
      return Success(tasks);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Marks a task as synced.
  Future<Result<void>> markTaskAsSynced(String taskId) async {
    try {
      await (_db.update(_db.tasksTable)..where((tbl) => tbl.id.equals(taskId)))
          .write(TasksTableCompanion(
        isSynced: const Value(true),
        lastSyncedAt: Value(DateTime.now()),
      ));
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Clears all cached data.
  Future<Result<void>> clearCache() async {
    try {
      await _db.delete(_db.tasksTable).go();
      await _db.delete(_db.projectsTable).go();
      await _db.delete(_db.sectionsTable).go();
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  // Helper methods to convert database rows to entities

  Task _taskRowToEntity(TasksTableData row) {
    return Task(
      userId: row.userId,
      id: row.id,
      projectId: row.projectId,
      sectionId: row.sectionId ?? '',
      parentId: row.parentId,
      addedByUid: row.addedByUid,
      assignedByUid: row.assignedByUid,
      responsibleUid: row.responsibleUid,
      labels: row.labels,
      deadline: row.deadline,
      duration: row.duration,
      checked: row.checked,
      isDeleted: row.isDeleted,
      addedAt: row.addedAt,
      completedAt: row.completedAt,
      completedByUid: row.completedByUid,
      updatedAt: row.updatedAt,
      due: row.due,
      priority: row.priority,
      childOrder: row.childOrder,
      content: row.content,
      description: row.description,
      noteCount: row.noteCount,
      dayOrder: row.dayOrder,
      isCollapsed: row.isCollapsed,
    );
  }

  Project _projectRowToEntity(ProjectsTableData row) {
    return Project(
      id: row.id,
      canAssignTasks: row.canAssignTasks,
      childOrder: row.childOrder,
      color: row.color,
      creatorUid: row.creatorUid,
      createdAt: row.createdAt,
      isArchived: row.isArchived,
      isDeleted: row.isDeleted,
      isFavorite: row.isFavorite,
      isFrozen: row.isFrozen,
      name: row.name,
      updatedAt: row.updatedAt,
      viewStyle: row.viewStyle,
      defaultOrder: row.defaultOrder,
      description: row.description,
      publicAccess: row.publicAccess,
      publicKey: row.publicKey,
      access: ProjectAccess(
        visibility: row.accessVisibility,
        configuration: row.accessConfiguration,
      ),
      role: row.role,
      parentId: row.parentId,
      inboxProject: row.inboxProject,
      isCollapsed: row.isCollapsed,
      isShared: row.isShared,
    );
  }

  Section _sectionRowToEntity(SectionsTableData row) {
    return Section(
      id: row.id,
      userId: row.userId,
      projectId: row.projectId,
      addedAt: row.addedAt,
      updatedAt: row.updatedAt,
      archivedAt: row.archivedAt,
      name: row.name,
      sectionOrder: row.sectionOrder,
      isArchived: row.isArchived,
      isDeleted: row.isDeleted,
      isCollapsed: row.isCollapsed,
    );
  }
}

