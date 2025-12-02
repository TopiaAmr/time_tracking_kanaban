import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_section_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetSection usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetSection(mockRepository);
  });

  test('should get single section by id from repository', () async {
    // arrange
    const tId = 's1';
    final section = Section(
      id: tId,
      userId: 'u1',
      projectId: 'p1',
      addedAt: DateTime.now(),
      updatedAt: DateTime.now(),
      archivedAt: null,
      name: 'Section 1',
      sectionOrder: 1,
      isArchived: false,
      isDeleted: false,
      isCollapsed: false,
    );

    when(
      mockRepository.getSection(tId),
    ).thenAnswer((_) async => Success(section));

    // act
    final result = await usecase(const GetSectionParams(tId));

    // assert
    expect(result, isA<Success<Section>>());
    expect((result as Success<Section>).value, section);
    verify(mockRepository.getSection(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
