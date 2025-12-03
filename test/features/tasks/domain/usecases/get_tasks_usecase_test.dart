import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_tasks_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetTasksUseCase usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetTasksUseCase(mockRepository);
  });

  test('should get list of tasks from repository', () async {
    // arrange
    final tasks = <Task>[];
    when(
      mockRepository.getTasks(
        projectId: anyNamed('projectId'),
        sectionId: anyNamed('sectionId'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => Success(tasks));

    // act
    final result = await usecase(const GetTasksParams());

    // assert
    expect(result, isA<Success<List<Task>>>());
    expect((result as Success<List<Task>>).value, tasks);
    verify(mockRepository.getTasks(forceRefresh: false)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass forceRefresh: true to repository when specified', () async {
    // arrange
    final tasks = <Task>[];
    when(
      mockRepository.getTasks(
        projectId: anyNamed('projectId'),
        sectionId: anyNamed('sectionId'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => Success(tasks));

    // act
    final result = await usecase(const GetTasksParams(forceRefresh: true));

    // assert
    expect(result, isA<Success<List<Task>>>());
    verify(mockRepository.getTasks(forceRefresh: true)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
