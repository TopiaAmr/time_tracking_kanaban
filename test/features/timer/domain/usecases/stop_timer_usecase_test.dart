import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/stop_timer_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/timer_repository_mock.mocks.dart';

void main() {
  late StopTimerUseCase usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTimerRepository();
    usecase = StopTimerUseCase(mockRepository);
  });

  test('should stop active timer via repository', () async {
    // arrange
    final tTimeLog = TimeLog(
      id: 'log-1',
      taskId: 'task-1',
      startTime: DateTime.now().subtract(const Duration(hours: 1)),
      endTime: DateTime.now(),
    );

    when(mockRepository.stopTimer()).thenAnswer((_) async => Success(tTimeLog));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, isA<Success<TimeLog>>());
    expect((result as Success<TimeLog>).value, tTimeLog);
    verify(mockRepository.stopTimer()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

