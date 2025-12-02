import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_comment_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/comments_repository_mock.mocks.dart';

void main() {
  late UpdateComment usecase;
  late MockCommentsRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockCommentsRepository();
    usecase = UpdateComment(mockRepository);
  });

  test('should update comment via repository', () async {
    // arrange
    const tCommentId = 'comment-1';
    const tNewContent = 'Updated comment content';
    final tUpdatedComment = Comment(
      id: tCommentId,
      taskId: 'task-1',
      content: tNewContent,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now(),
      authorId: 'user-1',
      authorName: 'John Doe',
      isSynced: true,
    );

    when(mockRepository.updateComment(tCommentId, tNewContent))
        .thenAnswer((_) async => Success(tUpdatedComment));

    // act
    final result = await usecase(const UpdateCommentParams(
      commentId: tCommentId,
      content: tNewContent,
    ));

    // assert
    expect(result, isA<Success<Comment>>());
    expect((result as Success<Comment>).value, tUpdatedComment);
    verify(mockRepository.updateComment(tCommentId, tNewContent)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

