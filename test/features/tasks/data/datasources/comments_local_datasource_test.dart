import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/comments_local_datasource.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/comment_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';

void main() {
  late AppDatabase database;
  late CommentsLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase(LazyDatabase(() async => NativeDatabase.memory()));
    dataSource = CommentsLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('CommentsLocalDataSource', () {
    test('should add and retrieve comments for a task', () async {
      final now = DateTime.now();
      final comment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Test Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: false,
      );

      final addResult = await dataSource.addComment(comment);
      expect(addResult, isA<Success<Comment>>());

      final retrieveResult = await dataSource.getCommentsForTask('task1');
      expect(retrieveResult, isA<Success<List<Comment>>>());
      if (retrieveResult is Success<List<Comment>>) {
        expect(retrieveResult.value.length, equals(1));
        expect(retrieveResult.value.first.id, equals('comment1'));
        expect(retrieveResult.value.first.content, equals('Test Comment'));
      }
    });

    test('should update a comment', () async {
      final now = DateTime.now();
      final comment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Original Content',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: false,
      );

      await dataSource.addComment(comment);

      final updatedComment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Updated Content',
        createdAt: now,
        updatedAt: now.add(const Duration(seconds: 1)),
        authorId: 'user1',
        isSynced: false,
      );

      final updateResult = await dataSource.updateComment(updatedComment);
      expect(updateResult, isA<Success<Comment>>());

      final retrieveResult = await dataSource.getCommentsForTask('task1');
      if (retrieveResult is Success<List<Comment>>) {
        expect(retrieveResult.value.first.content, equals('Updated Content'));
      }
    });

    test('should delete a comment', () async {
      final now = DateTime.now();
      final comment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Test Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: false,
      );

      await dataSource.addComment(comment);

      final deleteResult = await dataSource.deleteComment('comment1');
      expect(deleteResult, isA<Success<void>>());

      final retrieveResult = await dataSource.getCommentsForTask('task1');
      if (retrieveResult is Success<List<Comment>>) {
        expect(retrieveResult.value.length, equals(0));
      }
    });

    test('should get unsynced comments', () async {
      final now = DateTime.now();
      final comment1 = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Unsynced Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: false,
      );
      final comment2 = Comment(
        id: 'comment2',
        taskId: 'task1',
        content: 'Synced Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: true,
      );

      await dataSource.addComment(comment1);
      await dataSource.addComment(comment2);

      final result = await dataSource.getUnsyncedComments();
      expect(result, isA<Success<List<Comment>>>());
      if (result is Success<List<Comment>>) {
        expect(result.value.length, equals(1));
        expect(result.value.first.id, equals('comment1'));
      }
    });

    test('should mark comment as synced', () async {
      final now = DateTime.now();
      final comment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Test Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: false,
      );

      await dataSource.addComment(comment);

      final markResult = await dataSource.markCommentAsSynced('comment1');
      expect(markResult, isA<Success<void>>());

      final unsyncedResult = await dataSource.getUnsyncedComments();
      if (unsyncedResult is Success<List<Comment>>) {
        expect(unsyncedResult.value.length, equals(0));
      }
    });

    test('should cache comments from API', () async {
      final now = DateTime.now();
      final commentModel = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'API Comment',
        postedAt: now,
      );

      final cacheResult = await dataSource.cacheComments([commentModel], 'task1');
      expect(cacheResult, isA<Success<void>>());

      final retrieveResult = await dataSource.getCommentsForTask('task1');
      if (retrieveResult is Success<List<Comment>>) {
        expect(retrieveResult.value.length, equals(1));
        expect(retrieveResult.value.first.content, equals('API Comment'));
      }
    });
  });
}

