import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(LazyDatabase(() async => NativeDatabase.memory()));
  });

  tearDown(() async {
    await database.close();
  });

  group('AppDatabase', () {
    test('should create all tables', () async {
      // Verify tables exist by trying to query them
      final tasks = await database.select(database.tasksTable).get();
      final projects = await database.select(database.projectsTable).get();
      final sections = await database.select(database.sectionsTable).get();
      final comments = await database.select(database.commentsTable).get();
      final timeLogs = await database.select(database.timeLogsTable).get();

      expect(tasks, isA<List>());
      expect(projects, isA<List>());
      expect(sections, isA<List>());
      expect(comments, isA<List>());
      expect(timeLogs, isA<List>());
    });

    test('should insert and retrieve a task', () async {
      final now = DateTime.now();
      final task = TasksTableCompanion.insert(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: const Value('section1'),
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

      await database.into(database.tasksTable).insert(task);

      final query = database.select(database.tasksTable)
        ..where((t) => t.id.equals('task1'));
      final taskData = await query.getSingle();

      expect(taskData.id, equals('task1'));
      expect(taskData.content, equals('Test Task'));
      expect(taskData.userId, equals('user1'));
    });

    test('should insert and retrieve a comment', () async {
      final now = DateTime.now();
      final comment = CommentsTableCompanion.insert(
        id: 'comment1',
        taskId: 'task1',
        content: 'Test Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: const Value(false),
      );

      await database.into(database.commentsTable).insert(comment);

      final query = database.select(database.commentsTable)
        ..where((t) => t.id.equals('comment1'));
      final commentData = await query.getSingle();

      expect(commentData.id, equals('comment1'));
      expect(commentData.content, equals('Test Comment'));
      expect(commentData.taskId, equals('task1'));
    });

    test('should insert and retrieve a time log', () async {
      final now = DateTime.now();
      final timeLog = TimeLogsTableCompanion.insert(
        id: 'timer1',
        taskId: 'task1',
        startTime: now,
        endTime: const Value.absent(),
      );

      await database.into(database.timeLogsTable).insert(timeLog);

      final query = database.select(database.timeLogsTable)
        ..where((t) => t.id.equals('timer1'));
      final timeLogData = await query.getSingle();

      expect(timeLogData.id, equals('timer1'));
      expect(timeLogData.taskId, equals('task1'));
      expect(timeLogData.endTime, isNull);
    });

    test('should update a task', () async {
      final now = DateTime.now();
      final task = TasksTableCompanion.insert(
        userId: 'user1',
        id: 'task1',
        projectId: 'project1',
        sectionId: const Value('section1'),
        addedByUid: 'user1',
        labels: ['label1'],
        checked: false,
        isDeleted: false,
        addedAt: now,
        updatedAt: now,
        priority: 1,
        childOrder: 0,
        content: 'Original Content',
        description: 'Test Description',
        noteCount: 0,
        dayOrder: 0,
        isCollapsed: false,
      );

      await database.into(database.tasksTable).insert(task);

      await (database.update(database.tasksTable)
            ..where((t) => t.id.equals('task1')))
          .write(TasksTableCompanion(content: const Value('Updated Content')));

      final query = database.select(database.tasksTable)
        ..where((t) => t.id.equals('task1'));
      final taskData = await query.getSingle();

      expect(taskData.content, equals('Updated Content'));
    });

    test('should delete a comment', () async {
      final now = DateTime.now();
      final comment = CommentsTableCompanion.insert(
        id: 'comment1',
        taskId: 'task1',
        content: 'Test Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: const Value(false),
      );

      await database.into(database.commentsTable).insert(comment);

      await (database.delete(
        database.commentsTable,
      )..where((t) => t.id.equals('comment1'))).go();

      final query = database.select(database.commentsTable)
        ..where((t) => t.id.equals('comment1'));
      final result = await query.getSingleOrNull();

      expect(result, isNull);
    });
  });
}
