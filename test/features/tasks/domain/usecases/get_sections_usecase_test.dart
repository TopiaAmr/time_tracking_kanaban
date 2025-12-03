import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_sections_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/tasks_repository_mock.mocks.dart';

void main() {
  late GetSections usecase;
  late MockTasksRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTasksRepository();
    usecase = GetSections(mockRepository);
  });

  test('should get list of sections from repository', () async {
    // arrange
    final sections = <Section>[];
    when(
      mockRepository.getSections(
        projectId: anyNamed('projectId'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => Success(sections));

    // act
    final result = await usecase(const GetSectionsParams());

    // assert
    expect(result, isA<Success<List<Section>>>());
    expect((result as Success<List<Section>>).value, sections);
    verify(mockRepository.getSections(forceRefresh: false)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass forceRefresh: true to repository when specified', () async {
    // arrange
    final sections = <Section>[];
    when(
      mockRepository.getSections(
        projectId: anyNamed('projectId'),
        forceRefresh: anyNamed('forceRefresh'),
      ),
    ).thenAnswer((_) async => Success(sections));

    // act
    final result = await usecase(const GetSectionsParams(forceRefresh: true));

    // assert
    expect(result, isA<Success<List<Section>>>());
    verify(mockRepository.getSections(forceRefresh: true)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
