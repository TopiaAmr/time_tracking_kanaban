import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

/// Test data fixtures for integration tests.
///
/// Provides reusable test entities for consistent testing across flows.
class TestData {
  static final DateTime _now = DateTime.now();
  static const String testProjectId = 'test-project-1';
  static const String testUserId = 'test-user-1';

  // Sections (Kanban columns)
  static final Section todoSection = Section(
    id: 'section-todo',
    userId: testUserId,
    projectId: testProjectId,
    addedAt: _now,
    updatedAt: _now,
    name: 'To Do',
    sectionOrder: 0,
    isArchived: false,
    isDeleted: false,
    isCollapsed: false,
  );

  static final Section inProgressSection = Section(
    id: 'section-in-progress',
    userId: testUserId,
    projectId: testProjectId,
    addedAt: _now,
    updatedAt: _now,
    name: 'In Progress',
    sectionOrder: 1,
    isArchived: false,
    isDeleted: false,
    isCollapsed: false,
  );

  static final Section doneSection = Section(
    id: 'section-done',
    userId: testUserId,
    projectId: testProjectId,
    addedAt: _now,
    updatedAt: _now,
    name: 'Done',
    sectionOrder: 2,
    isArchived: false,
    isDeleted: false,
    isCollapsed: false,
  );

  static List<Section> get allSections => [
        todoSection,
        inProgressSection,
        doneSection,
      ];

  // Project
  static final Project testProject = Project(
    id: testProjectId,
    canAssignTasks: true,
    childOrder: 0,
    color: '#3498db',
    creatorUid: testUserId,
    createdAt: _now,
    isArchived: false,
    isDeleted: false,
    isFavorite: false,
    isFrozen: false,
    name: 'Test Project',
    updatedAt: _now,
    viewStyle: 'board',
    defaultOrder: 0,
    description: 'Test project for integration tests',
    publicAccess: false,
    publicKey: '',
    access: const ProjectAccess(visibility: 'private', configuration: {}),
    role: 'owner',
    inboxProject: false,
    isCollapsed: false,
    isShared: false,
  );

  // Tasks in To Do column
  static final Task todoTask1 = Task(
    userId: testUserId,
    id: 'task-todo-1',
    projectId: testProjectId,
    sectionId: todoSection.id,
    addedByUid: testUserId,
    labels: const [],
    checked: false,
    isDeleted: false,
    addedAt: _now,
    updatedAt: _now,
    priority: 1,
    childOrder: 0,
    content: 'Todo Task 1',
    description: 'First task in To Do column',
    noteCount: 0,
    dayOrder: 0,
    isCollapsed: false,
  );

  static final Task todoTask2 = Task(
    userId: testUserId,
    id: 'task-todo-2',
    projectId: testProjectId,
    sectionId: todoSection.id,
    addedByUid: testUserId,
    labels: const [],
    checked: false,
    isDeleted: false,
    addedAt: _now,
    updatedAt: _now,
    priority: 2,
    childOrder: 1,
    content: 'Todo Task 2',
    description: 'Second task in To Do column',
    noteCount: 0,
    dayOrder: 1,
    isCollapsed: false,
  );

  // Tasks in In Progress column
  static final Task inProgressTask1 = Task(
    userId: testUserId,
    id: 'task-in-progress-1',
    projectId: testProjectId,
    sectionId: inProgressSection.id,
    addedByUid: testUserId,
    labels: const [],
    checked: false,
    isDeleted: false,
    addedAt: _now,
    updatedAt: _now,
    priority: 1,
    childOrder: 0,
    content: 'In Progress Task 1',
    description: 'First task in In Progress column',
    noteCount: 2,
    dayOrder: 0,
    isCollapsed: false,
  );

  static final Task inProgressTask2 = Task(
    userId: testUserId,
    id: 'task-in-progress-2',
    projectId: testProjectId,
    sectionId: inProgressSection.id,
    addedByUid: testUserId,
    labels: const [],
    checked: false,
    isDeleted: false,
    addedAt: _now,
    updatedAt: _now,
    priority: 3,
    childOrder: 1,
    content: 'In Progress Task 2',
    description: 'Second task in In Progress column',
    noteCount: 0,
    dayOrder: 1,
    isCollapsed: false,
  );

  // Tasks in Done column
  static final Task doneTask1 = Task(
    userId: testUserId,
    id: 'task-done-1',
    projectId: testProjectId,
    sectionId: doneSection.id,
    addedByUid: testUserId,
    labels: const [],
    checked: true,
    isDeleted: false,
    addedAt: _now.subtract(const Duration(days: 2)),
    updatedAt: _now.subtract(const Duration(days: 1)),
    completedAt: _now.subtract(const Duration(days: 1)),
    priority: 1,
    childOrder: 0,
    content: 'Done Task 1',
    description: 'Completed task',
    noteCount: 1,
    dayOrder: 0,
    isCollapsed: false,
  );

  static List<Task> get allTasks => [
        todoTask1,
        todoTask2,
        inProgressTask1,
        inProgressTask2,
        doneTask1,
      ];

  static List<Task> get todoTasks => [todoTask1, todoTask2];
  static List<Task> get inProgressTasks => [inProgressTask1, inProgressTask2];
  static List<Task> get doneTasks => [doneTask1];

  // Comments
  static final Comment comment1 = Comment(
    id: 'comment-1',
    taskId: inProgressTask1.id,
    content: 'This is the first comment',
    createdAt: _now.subtract(const Duration(hours: 2)),
    updatedAt: _now.subtract(const Duration(hours: 2)),
    authorId: testUserId,
    authorName: 'Test User',
    isSynced: true,
  );

  static final Comment comment2 = Comment(
    id: 'comment-2',
    taskId: inProgressTask1.id,
    content: 'This is the second comment',
    createdAt: _now.subtract(const Duration(hours: 1)),
    updatedAt: _now.subtract(const Duration(hours: 1)),
    authorId: testUserId,
    authorName: 'Test User',
    isSynced: true,
  );

  static List<Comment> get taskComments => [comment1, comment2];

  // Time Logs
  static final TimeLog activeTimeLog = TimeLog(
    id: 'time-log-1',
    taskId: inProgressTask1.id,
    startTime: _now.subtract(const Duration(minutes: 30)),
    endTime: null, // Active timer
  );

  static final TimeLog completedTimeLog = TimeLog(
    id: 'time-log-2',
    taskId: doneTask1.id,
    startTime: _now.subtract(const Duration(hours: 3)),
    endTime: _now.subtract(const Duration(hours: 2)),
  );

  static List<TimeLog> get allTimeLogs => [activeTimeLog, completedTimeLog];

  /// Creates a new task for testing task creation.
  static Task createNewTask({
    String? content,
    String? description,
    String? sectionId,
  }) {
    final now = DateTime.now();
    return Task(
      userId: testUserId,
      id: 'temp-${now.millisecondsSinceEpoch}',
      projectId: testProjectId,
      sectionId: sectionId ?? todoSection.id,
      addedByUid: testUserId,
      labels: const [],
      checked: false,
      isDeleted: false,
      addedAt: now,
      updatedAt: now,
      priority: 1,
      childOrder: 0,
      content: content ?? 'New Test Task',
      description: description ?? 'Test task description',
      noteCount: 0,
      dayOrder: 0,
      isCollapsed: false,
    );
  }
}
