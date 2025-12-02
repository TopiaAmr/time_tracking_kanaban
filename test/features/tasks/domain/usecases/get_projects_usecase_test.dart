import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_projects_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetProjects usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetProjects(mockRepository);
  });

  test('should get list of projects from repository', () async {
    // arrange
    final projects = <Project>[];
    when(
      mockRepository.getProjects(),
    ).thenAnswer((_) async => Success(projects));

    // act
    final result = await usecase(NoParams());

    // assert
    expect(result, isA<Success<List<Project>>>());
    expect((result as Success<List<Project>>).value, projects);
    verify(mockRepository.getProjects()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
