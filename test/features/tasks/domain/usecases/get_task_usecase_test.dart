import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_task_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetTask usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetTask(mockRepository);
  });

  test('should get a single task by id from repository', () async {
    // arrange
    const tId = '123';
    final task = Task(
      id: tId,
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
      content: 'Test task',
      description: 'desc',
      noteCount: 0,
      dayOrder: 0,
      isCollapsed: false,
    );

    when(mockRepository.getTask(tId)).thenAnswer((_) async => Success(task));

    // act
    final result = await usecase(const GetTaskParams(tId));

    // assert
    expect(result, isA<Success<Task>>());
    expect((result as Success<Task>).value, task);
    verify(mockRepository.getTask(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
