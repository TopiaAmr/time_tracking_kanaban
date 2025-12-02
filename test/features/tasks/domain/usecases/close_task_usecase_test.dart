import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/close_task_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late CloseTaskUseCase usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = CloseTaskUseCase(mockRepository);
  });

  test('should close task via repository with updated fields', () async {
    // arrange
    final originalTask = Task(
      id: '1',
      userId: 'u1',
      projectId: 'p1',
      sectionId: 's1',
      parentId: null,
      addedByUid: 'adder',
      assignedByUid: null,
      responsibleUid: null,
      labels: const [],
      deadline: null,
      duration: null,
      checked: false,
      isDeleted: false,
      addedAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: null,
      completedByUid: null,
      updatedAt: DateTime.now(),
      due: null,
      priority: 1,
      childOrder: 1,
      content: 'Close me',
      description: 'desc',
      noteCount: 0,
      dayOrder: 0,
      isCollapsed: false,
    );

    when(mockRepository.updateTask(argThat(isA<Task>()))).thenAnswer((
      invocation,
    ) async {
      final updatedTaskArg = invocation.positionalArguments.first as Task;
      return Success(updatedTaskArg);
    });

    // act
    final result = await usecase(CloseTaskParams(originalTask));

    // assert
    expect(result, isA<Success<Task>>());
    final updated = (result as Success<Task>).value;

    expect(updated.checked, true);
    expect(updated.completedAt, isNotNull);
    expect(updated.updatedAt, isNotNull);

    verify(mockRepository.updateTask(argThat(isA<Task>()))).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
