import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';

void main() {
  group('Comment', () {
    const tId = 'comment-1';
    const tTaskId = 'task-1';
    const tContent = 'This is a test comment';
    final tCreatedAt = DateTime(2024, 1, 1, 10, 0, 0);
    final tUpdatedAt = DateTime(2024, 1, 1, 10, 0, 0);
    const tAuthorId = 'user-1';
    const tAuthorName = 'John Doe';

    test('should be a valid Comment entity', () {
      // arrange & act
      final comment = Comment(
        id: tId,
        taskId: tTaskId,
        content: tContent,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
        authorId: tAuthorId,
        authorName: tAuthorName,
        isSynced: true,
      );

      // assert
      expect(comment.id, tId);
      expect(comment.taskId, tTaskId);
      expect(comment.content, tContent);
      expect(comment.createdAt, tCreatedAt);
      expect(comment.updatedAt, tUpdatedAt);
      expect(comment.authorId, tAuthorId);
      expect(comment.authorName, tAuthorName);
      expect(comment.isSynced, isTrue);
    });

    test('should allow null authorName', () {
      // arrange & act
      final comment = Comment(
        id: tId,
        taskId: tTaskId,
        content: tContent,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
        authorId: tAuthorId,
        authorName: null,
        isSynced: false,
      );

      // assert
      expect(comment.authorName, isNull);
      expect(comment.isSynced, isFalse);
    });

    test('should be equal when properties match', () {
      // arrange
      final comment1 = Comment(
        id: tId,
        taskId: tTaskId,
        content: tContent,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
        authorId: tAuthorId,
        authorName: tAuthorName,
        isSynced: true,
      );
      final comment2 = Comment(
        id: tId,
        taskId: tTaskId,
        content: tContent,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
        authorId: tAuthorId,
        authorName: tAuthorName,
        isSynced: true,
      );

      // act & assert
      expect(comment1, equals(comment2));
    });

    test('should not be equal when properties differ', () {
      // arrange
      final comment1 = Comment(
        id: tId,
        taskId: tTaskId,
        content: tContent,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
        authorId: tAuthorId,
        authorName: tAuthorName,
        isSynced: true,
      );
      final comment2 = Comment(
        id: tId,
        taskId: tTaskId,
        content: 'Different content',
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
        authorId: tAuthorId,
        authorName: tAuthorName,
        isSynced: true,
      );

      // act & assert
      expect(comment1, isNot(equals(comment2)));
    });
  });
}

