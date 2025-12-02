import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_comment_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/delete_comment_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_task_comments_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_comment_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/cubit/comments_cubit.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/cubit/comments_state.dart';

import '../../../../mocks/mock_setup.dart';
import 'comments_cubit_test.mocks.dart';

@GenerateMocks([
  GetTaskComments,
  AddComment,
  UpdateComment,
  DeleteComment,
])
void main() {
  late CommentsCubit commentsCubit;
  late MockGetTaskComments mockGetTaskComments;
  late MockAddComment mockAddComment;
  late MockUpdateComment mockUpdateComment;
  late MockDeleteComment mockDeleteComment;

  final dummyDateTime = DateTime(2024, 1, 1);

  Comment createComment({
    required String id,
    required String taskId,
    required String content,
  }) {
    return Comment(
      id: id,
      taskId: taskId,
      content: content,
      createdAt: dummyDateTime,
      updatedAt: dummyDateTime,
      authorId: 'user1',
      authorName: null,
      isSynced: true,
    );
  }

  setUp(() {
    setupMockDummyValues();
    mockGetTaskComments = MockGetTaskComments();
    mockAddComment = MockAddComment();
    mockUpdateComment = MockUpdateComment();
    mockDeleteComment = MockDeleteComment();

    commentsCubit = CommentsCubit(
      mockGetTaskComments,
      mockAddComment,
      mockUpdateComment,
      mockDeleteComment,
    );
  });

  tearDown(() {
    commentsCubit.close();
  });

  group('CommentsCubit', () {
    test('initial state is CommentsInitial', () {
      expect(commentsCubit.state, const CommentsInitial());
    });

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsLoaded] when loadComments succeeds',
      build: () {
        final comments = [
          createComment(id: '1', taskId: 'task1', content: 'Comment 1'),
          createComment(id: '2', taskId: 'task1', content: 'Comment 2'),
        ];
        when(mockGetTaskComments(any)).thenAnswer(
          (_) async => Success(comments),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.loadComments('task1'),
      expect: () => [
        const CommentsLoading(),
        CommentsLoaded([
          createComment(id: '1', taskId: 'task1', content: 'Comment 1'),
          createComment(id: '2', taskId: 'task1', content: 'Comment 2'),
        ]),
      ],
      verify: (_) {
        verify(mockGetTaskComments(any)).called(1);
      },
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsError] when loadComments fails',
      build: () {
        when(mockGetTaskComments(any)).thenAnswer(
          (_) async => const Error<List<Comment>>(ServerFailure()),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.loadComments('task1'),
      expect: () => [
        const CommentsLoading(),
        const CommentsError(ServerFailure()),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsLoaded] when addComment succeeds',
      build: () {
        final newComment = createComment(
          id: '3',
          taskId: 'task1',
          content: 'New comment',
        );
        when(mockAddComment(any)).thenAnswer(
          (_) async => Success(newComment),
        );
        when(mockGetTaskComments(any)).thenAnswer(
          (_) async => Success([newComment]),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.addComment('task1', 'New comment'),
      expect: () => [
        const CommentsLoading(),
        CommentsLoaded([
          createComment(
            id: '3',
            taskId: 'task1',
            content: 'New comment',
          ),
        ]),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsError] when addComment fails',
      build: () {
        when(mockAddComment(any)).thenAnswer(
          (_) async => const Error<Comment>(ServerFailure()),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.addComment('task1', 'New comment'),
      expect: () => [
        const CommentsLoading(),
        const CommentsError(ServerFailure()),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsLoaded] when updateComment succeeds',
      build: () {
        final updatedComment = createComment(
          id: '1',
          taskId: 'task1',
          content: 'Updated comment',
        );
        when(mockUpdateComment(any)).thenAnswer(
          (_) async => Success(updatedComment),
        );
        when(mockGetTaskComments(any)).thenAnswer(
          (_) async => Success([updatedComment]),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.updateComment(
        createComment(id: '1', taskId: 'task1', content: 'Old comment'),
        'Updated comment',
      ),
      expect: () => [
        const CommentsLoading(),
        CommentsLoaded([
          createComment(
            id: '1',
            taskId: 'task1',
            content: 'Updated comment',
          ),
        ]),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsError] when updateComment fails',
      build: () {
        when(mockUpdateComment(any)).thenAnswer(
          (_) async => const Error<Comment>(ServerFailure()),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.updateComment(
        createComment(id: '1', taskId: 'task1', content: 'Old comment'),
        'Updated comment',
      ),
      expect: () => [
        const CommentsLoading(),
        const CommentsError(ServerFailure()),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsLoaded] when deleteComment succeeds',
      build: () {
        when(mockDeleteComment(any)).thenAnswer(
          (_) async => const Success<void>(null),
        );
        when(mockGetTaskComments(any)).thenAnswer(
          (_) async => const Success<List<Comment>>([]),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.deleteComment('1', 'task1'),
      expect: () => [
        const CommentsLoading(),
        const CommentsLoaded([]),
      ],
    );

    blocTest<CommentsCubit, CommentsState>(
      'emits [CommentsLoading, CommentsError] when deleteComment fails',
      build: () {
        when(mockDeleteComment(any)).thenAnswer(
          (_) async => const Error<void>(ServerFailure()),
        );
        return commentsCubit;
      },
      act: (cubit) => cubit.deleteComment('1', 'task1'),
      expect: () => [
        const CommentsLoading(),
        const CommentsError(ServerFailure()),
      ],
    );
  });
}

