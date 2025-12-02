import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_task_comments_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/comments_repository_mock.mocks.dart';

void main() {
  late GetTaskComments usecase;
  late MockCommentsRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockCommentsRepository();
    usecase = GetTaskComments(mockRepository);
  });

  test('should get comments for a task from repository', () async {
    // arrange
    const tTaskId = 'task-1';
    final tComments = [
      Comment(
        id: 'comment-1',
        taskId: tTaskId,
        content: 'First comment',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        authorId: 'user-1',
        authorName: 'John Doe',
        isSynced: true,
      ),
      Comment(
        id: 'comment-2',
        taskId: tTaskId,
        content: 'Second comment',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
        authorId: 'user-2',
        authorName: null,
        isSynced: true,
      ),
    ];

    when(mockRepository.getCommentsForTask(tTaskId))
        .thenAnswer((_) async => Success(tComments));

    // act
    final result = await usecase(const GetTaskCommentsParams(tTaskId));

    // assert
    expect(result, isA<Success<List<Comment>>>());
    expect((result as Success<List<Comment>>).value, tComments);
    verify(mockRepository.getCommentsForTask(tTaskId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

