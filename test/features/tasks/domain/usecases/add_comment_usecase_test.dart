import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_comment_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/comments_repository_mock.mocks.dart';

void main() {
  late AddComment usecase;
  late MockCommentsRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockCommentsRepository();
    usecase = AddComment(mockRepository);
  });

  test('should add comment to a task via repository', () async {
    // arrange
    const tTaskId = 'task-1';
    const tContent = 'This is a new comment';
    final tComment = Comment(
      id: 'comment-1',
      taskId: tTaskId,
      content: tContent,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      authorId: 'user-1',
      authorName: 'John Doe',
      isSynced: true,
    );

    when(mockRepository.addComment(tTaskId, tContent))
        .thenAnswer((_) async => Success(tComment));

    // act
    final result = await usecase(const AddCommentParams(
      taskId: tTaskId,
      content: tContent,
    ));

    // assert
    expect(result, isA<Success<Comment>>());
    expect((result as Success<Comment>).value, tComment);
    verify(mockRepository.addComment(tTaskId, tContent)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

