import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/comment_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';

void main() {
  group('CommentModel', () {
    final now = DateTime.now();
    final commentModelJson = {
      'id': 'comment1',
      'posted_uid': 'user1',
      'content': 'Test comment',
      'file_attachment': null,
      'uids_to_notify': null,
      'is_deleted': false,
      'posted_at': now.toIso8601String(),
      'reactions': null,
    };

    test('should create CommentModel from JSON', () {
      final model = CommentModel.fromJson(commentModelJson);

      expect(model.id, 'comment1');
      expect(model.postedUid, 'user1');
      expect(model.content, 'Test comment');
      expect(model.isDeleted, false);
      expect(model.fileAttachment, isNull);
      expect(model.uidsToNotify, isNull);
      expect(model.reactions, isNull);
    });

    test('should convert CommentModel to JSON', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Test comment',
        fileAttachment: null,
        uidsToNotify: null,
        isDeleted: false,
        postedAt: now,
        reactions: null,
      );

      final json = model.toJson();

      expect(json['id'], 'comment1');
      expect(json['posted_uid'], 'user1');
      expect(json['content'], 'Test comment');
      expect(json['is_deleted'], false);
    });

    test('should convert CommentModel to Comment entity', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Test comment',
        fileAttachment: null,
        uidsToNotify: null,
        isDeleted: false,
        postedAt: now,
        reactions: null,
      );

      final entity = model.toEntity(taskId: 'task1', isSynced: true);

      expect(entity, isA<Comment>());
      expect(entity.id, 'comment1');
      expect(entity.taskId, 'task1');
      expect(entity.content, 'Test comment');
      expect(entity.authorId, 'user1');
      expect(entity.isSynced, true);
      expect(entity.createdAt, now);
      expect(entity.updatedAt, now);
    });

    test('should handle unsynced comment', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Unsynced comment',
        fileAttachment: null,
        uidsToNotify: null,
        isDeleted: false,
        postedAt: now,
        reactions: null,
      );

      final entity = model.toEntity(taskId: 'task1', isSynced: false);
      expect(entity.isSynced, false);
    });

    test('should handle deleted comment', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Deleted comment',
        fileAttachment: null,
        uidsToNotify: null,
        isDeleted: true,
        postedAt: now,
        reactions: null,
      );

      expect(model.isDeleted, true);
    });

    test('should handle comment with file attachment', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Comment with attachment',
        fileAttachment: {
          'file_name': 'test.pdf',
          'file_size': 1024,
        },
        uidsToNotify: null,
        isDeleted: false,
        postedAt: now,
        reactions: null,
      );

      expect(model.fileAttachment, isNotNull);
      expect(model.fileAttachment!['file_name'], 'test.pdf');
    });

    test('should handle comment with uids to notify', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Comment with notifications',
        fileAttachment: null,
        uidsToNotify: ['user2', 'user3'],
        isDeleted: false,
        postedAt: now,
        reactions: null,
      );

      expect(model.uidsToNotify, isNotNull);
      expect(model.uidsToNotify!.length, 2);
      expect(model.uidsToNotify, contains('user2'));
      expect(model.uidsToNotify, contains('user3'));
    });

    test('should handle comment with reactions', () {
      final model = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'Comment with reactions',
        fileAttachment: null,
        uidsToNotify: null,
        isDeleted: false,
        postedAt: now,
        reactions: {
          '👍': ['user2', 'user3'],
          '❤️': ['user1'],
        },
      );

      expect(model.reactions, isNotNull);
      expect(model.reactions!['👍'], ['user2', 'user3']);
      expect(model.reactions!['❤️'], ['user1']);
    });

    test('should use default isDeleted value when not provided', () {
      final jsonWithoutDeleted = {
        'id': 'comment1',
        'posted_uid': 'user1',
        'content': 'Test comment',
        'posted_at': now.toIso8601String(),
      };

      final model = CommentModel.fromJson(jsonWithoutDeleted);
      expect(model.isDeleted, false);
    });
  });

  group('CreateCommentBody', () {
    test('should create CreateCommentBody from JSON', () {
      final json = {
        'content': 'New comment',
        'project_id': 'project1',
        'task_id': 'task1',
      };

      final body = CreateCommentBody.fromJson(json);

      expect(body.content, 'New comment');
      expect(body.projectId, 'project1');
      expect(body.taskId, 'task1');
    });

    test('should convert CreateCommentBody to JSON', () {
      final body = CreateCommentBody(
        content: 'New comment',
        projectId: 'project1',
        taskId: 'task1',
      );

      final json = body.toJson();

      expect(json['content'], 'New comment');
      expect(json['project_id'], 'project1');
      expect(json['task_id'], 'task1');
    });

    test('should handle CreateCommentBody with only content', () {
      final body = CreateCommentBody(
        content: 'Comment without project/task',
        projectId: null,
        taskId: null,
      );

      final json = body.toJson();
      expect(json['content'], 'Comment without project/task');
      expect(json['project_id'], isNull);
      expect(json['task_id'], isNull);
    });
  });

  group('UpdateCommentBody', () {
    test('should create UpdateCommentBody from JSON', () {
      final json = {'content': 'Updated comment'};

      final body = UpdateCommentBody.fromJson(json);

      expect(body.content, 'Updated comment');
    });

    test('should convert UpdateCommentBody to JSON', () {
      final body = UpdateCommentBody(content: 'Updated comment');

      final json = body.toJson();

      expect(json['content'], 'Updated comment');
    });
  });

  group('CommentsResponse', () {
    test('should create CommentsResponse from JSON', () {
      final now = DateTime.now();
      final json = {
        'results': [
          {
            'id': 'comment1',
            'posted_uid': 'user1',
            'content': 'Comment 1',
            'is_deleted': false,
            'posted_at': now.toIso8601String(),
          },
          {
            'id': 'comment2',
            'posted_uid': 'user2',
            'content': 'Comment 2',
            'is_deleted': false,
            'posted_at': now.toIso8601String(),
          },
        ],
        'next_cursor': 'cursor123',
      };

      final response = CommentsResponse.fromJson(json);

      expect(response.results.length, 2);
      expect(response.results.first.id, 'comment1');
      expect(response.nextCursor, 'cursor123');
    });

    test('should convert CommentsResponse to JSON', () {
      final now = DateTime.now();
      final response = CommentsResponse(
        results: [
          CommentModel(
            id: 'comment1',
            postedUid: 'user1',
            content: 'Comment 1',
            isDeleted: false,
            postedAt: now,
          ),
        ],
        nextCursor: 'cursor123',
      );

      final json = response.toJson();

      expect(json['results'], isA<List>());
      expect(json['next_cursor'], 'cursor123');
    });

    test('should handle CommentsResponse without next cursor', () {
      final now = DateTime.now();
      final json = {
        'results': [
          {
            'id': 'comment1',
            'posted_uid': 'user1',
            'content': 'Comment 1',
            'is_deleted': false,
            'posted_at': now.toIso8601String(),
          },
        ],
        'next_cursor': null,
      };

      final response = CommentsResponse.fromJson(json);

      expect(response.nextCursor, isNull);
    });
  });
}

