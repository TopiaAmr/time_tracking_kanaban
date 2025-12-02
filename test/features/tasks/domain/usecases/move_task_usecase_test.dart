import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/move_task_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late MoveTask usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = MoveTask(mockRepository);
  });

  test('should move task via repository', () async {
    // arrange
    final task = Task(
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
      addedAt: DateTime.now(),
      completedAt: null,
      completedByUid: null,
      updatedAt: DateTime.now(),
      due: null,
      priority: 1,
      childOrder: 1,
      content: 'Move me',
      description: 'desc',
      noteCount: 0,
      dayOrder: 0,
      isCollapsed: false,
    );

    const newProjectId = 'p2';
    const newSectionId = 's2';

    when(
      mockRepository.moveTask(task, newProjectId, newSectionId),
    ).thenAnswer((_) async => Success(task));

    // act
    final result = await usecase(
      MoveTaskParams(
        task: task,
        projectId: newProjectId,
        sectionId: newSectionId,
      ),
    );

    // assert
    expect(result, isA<Success<Task>>());
    expect((result as Success<Task>).value, task);
    verify(mockRepository.moveTask(task, newProjectId, newSectionId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
