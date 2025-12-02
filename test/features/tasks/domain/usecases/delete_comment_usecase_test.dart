import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/delete_comment_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/comments_repository_mock.mocks.dart';

void main() {
  late DeleteComment usecase;
  late MockCommentsRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockCommentsRepository();
    usecase = DeleteComment(mockRepository);
  });

  test('should delete comment via repository', () async {
    // arrange
    const tCommentId = 'comment-1';

    when(mockRepository.deleteComment(tCommentId))
        .thenAnswer((_) async => Success<void>(null as dynamic));

    // act
    final result = await usecase(const DeleteCommentParams(tCommentId));

    // assert
    expect(result, isA<Success<void>>());
    verify(mockRepository.deleteComment(tCommentId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

