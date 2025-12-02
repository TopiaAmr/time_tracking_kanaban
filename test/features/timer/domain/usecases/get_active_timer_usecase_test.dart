import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_active_timer_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/timer_repository_mock.mocks.dart';

void main() {
  late GetActiveTimerUseCase usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTimerRepository();
    usecase = GetActiveTimerUseCase(mockRepository);
  });

  test('should get active timer from repository when one exists', () async {
    // arrange
    final tTimeLog = TimeLog(
      id: 'log-1',
      taskId: 'task-1',
      startTime: DateTime.now().subtract(const Duration(minutes: 15)),
      endTime: null,
    );

    when(mockRepository.getActiveTimer())
        .thenAnswer((_) async => Success<TimeLog?>(tTimeLog));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, isA<Success<TimeLog?>>());
    expect((result as Success<TimeLog?>).value, tTimeLog);
    verify(mockRepository.getActiveTimer()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return null when no active timer exists', () async {
    // arrange
    when(mockRepository.getActiveTimer())
        .thenAnswer((_) async => const Success<TimeLog?>(null));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, isA<Success<TimeLog?>>());
    expect((result as Success<TimeLog?>).value, isNull);
    verify(mockRepository.getActiveTimer()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

