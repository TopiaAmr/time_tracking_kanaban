import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_tasks_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetTasks usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetTasks(mockRepository);
  });

  test('should get list of tasks from repository', () async {
    // arrange
    final tasks = <Task>[];
    when(
      mockRepository.getTasks(
        projectId: anyNamed('projectId'),
        sectionId: anyNamed('sectionId'),
      ),
    ).thenAnswer((_) async => Success(tasks));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, isA<Success<List<Task>>>());
    expect((result as Success<List<Task>>).value, tasks);
    verify(mockRepository.getTasks(projectId: null, sectionId: null)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
