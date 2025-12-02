import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/network/connectivity_service.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/comments_local_datasource.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/comment_model.dart';
import 'package:time_tracking_kanaban/features/tasks/data/repositories/comments_repository_impl.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import '../../../../mocks/mock_setup.dart';

import 'comments_repository_impl_test.mocks.dart';

@GenerateMocks([
  TodoistApi,
  CommentsLocalDataSource,
  ConnectivityService,
])
void main() {
  late CommentsRepositoryImpl repository;
  late MockTodoistApi mockApi;
  late MockCommentsLocalDataSource mockLocalDataSource;
  late MockConnectivityService mockConnectivityService;

  setUp(() {
    setupMockDummyValues();
    mockApi = MockTodoistApi();
    mockLocalDataSource = MockCommentsLocalDataSource();
    mockConnectivityService = MockConnectivityService();
    repository = CommentsRepositoryImpl(
      mockApi,
      mockLocalDataSource,
      mockConnectivityService,
    );
  });

  group('CommentsRepositoryImpl - Online scenarios', () {
    test('should fetch comments from API and cache when online', () async {
      final now = DateTime.now();
      final commentModel = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'API Comment',
        postedAt: now,
      );
      final response = CommentsResponse(results: [commentModel], nextCursor: null);

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockApi.getComments(taskId: 'task1')).thenAnswer((_) async => response);
      when(mockLocalDataSource.cacheComments([commentModel], 'task1'))
          .thenAnswer((_) async => const Success<void>(null));
      when(mockLocalDataSource.getCommentsForTask('task1'))
          .thenAnswer((_) async => Success([commentModel.toEntity(taskId: 'task1')]));

      final result = await repository.getCommentsForTask('task1');

      expect(result, isA<Success<List<Comment>>>());
      verify(mockApi.getComments(taskId: 'task1')).called(1);
      verify(mockLocalDataSource.cacheComments([commentModel], 'task1')).called(1);
    });

    test('should create comment via API when online', () async {
      final now = DateTime.now();
      final commentModel = CommentModel(
        id: 'comment1',
        postedUid: 'user1',
        content: 'New Comment',
        postedAt: now,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockApi.addComment(any)).thenAnswer((_) async => commentModel);
      when(mockLocalDataSource.addComment(any))
          .thenAnswer((_) async => Success(commentModel.toEntity(taskId: 'task1')));

      final result = await repository.addComment('task1', 'New Comment');

      expect(result, isA<Success<Comment>>());
      verify(mockApi.addComment(any)).called(1);
    });
  });

  group('CommentsRepositoryImpl - Offline scenarios', () {
    test('should return cached comments when offline', () async {
      final now = DateTime.now();
      final comment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Cached Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: true,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);
      when(mockLocalDataSource.getCommentsForTask('task1'))
          .thenAnswer((_) async => Success([comment]));

      final result = await repository.getCommentsForTask('task1');

      expect(result, isA<Success<List<Comment>>>());
      verifyNever(mockApi.getComments(taskId: anyNamed('taskId')));
      verify(mockLocalDataSource.getCommentsForTask('task1')).called(1);
    });

    test('should store comment locally when creating offline', () async {
      when(mockConnectivityService.isConnected()).thenAnswer((_) async => false);
      when(mockLocalDataSource.addComment(any)).thenAnswer((invocation) async {
        final comment = invocation.positionalArguments[0] as Comment;
        return Success(comment);
      });

      final result = await repository.addComment('task1', 'New Comment');

      expect(result, isA<Success<Comment>>());
      verifyNever(mockApi.addComment(any));
      
      final capturedComments = verify(mockLocalDataSource.addComment(captureAny)).captured;
      expect(capturedComments.length, 1);
      
      // Verify the comment properties
      final comment = capturedComments.first as Comment;
      expect(comment.taskId, 'task1');
      expect(comment.content, 'New Comment');
      expect(comment.isSynced, false);
      expect(comment.id, startsWith('temp_'));
    });
  });

  group('CommentsRepositoryImpl - Sync', () {
    test('should sync pending comments when online', () async {
      final now = DateTime.now();
      final unsyncedComment = Comment(
        id: 'comment1',
        taskId: 'task1',
        content: 'Unsynced Comment',
        createdAt: now,
        updatedAt: now,
        authorId: 'user1',
        isSynced: false,
      );

      when(mockConnectivityService.isConnected()).thenAnswer((_) async => true);
      when(mockLocalDataSource.getUnsyncedComments())
          .thenAnswer((_) async => Success([unsyncedComment]));
      when(mockApi.updateComment(any, any)).thenAnswer((_) async => CommentModel(
            id: 'comment1',
            postedUid: 'user1',
            content: 'Unsynced Comment',
            postedAt: now,
          ));
      when(mockLocalDataSource.markCommentAsSynced('comment1'))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await repository.syncPendingChanges();

      expect(result, isA<Success<void>>());
      verify(mockLocalDataSource.getUnsyncedComments()).called(1);
    });
  });
}

