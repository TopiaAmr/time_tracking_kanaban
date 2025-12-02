import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_project_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetProject usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetProject(mockRepository);
  });

  test('should get single project by id from repository', () async {
    // arrange
    const tId = 'p1';
    final project = Project(
      id: tId,
      canAssignTasks: true,
      childOrder: 1,
      color: 'red',
      creatorUid: 'creator',
      createdAt: DateTime.now(),
      isArchived: false,
      isDeleted: false,
      isFavorite: false,
      isFrozen: false,
      name: 'Project 1',
      updatedAt: DateTime.now(),
      viewStyle: 'board',
      defaultOrder: 0,
      description: 'desc',
      publicAccess: false,
      publicKey: 'key',
      access: const ProjectAccess(visibility: 'private', configuration: {}),
      role: 'owner',
      parentId: null,
      inboxProject: false,
      isCollapsed: false,
      isShared: false,
    );

    when(
      mockRepository.getProject(tId),
    ).thenAnswer((_) async => Success(project));

    // act
    final result = await usecase(const GetProjectParams(tId));

    // assert
    expect(result, isA<Success<Project>>());
    expect((result as Success<Project>).value, project);
    verify(mockRepository.getProject(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
