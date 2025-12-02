import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/resume_timer_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/timer_repository_mock.mocks.dart';

void main() {
  late ResumeTimerUseCase usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTimerRepository();
    usecase = ResumeTimerUseCase(mockRepository);
  });

  test('should resume timer for a task via repository', () async {
    // arrange
    const tTaskId = 'task-1';
    final tTimeLog = TimeLog(
      id: 'log-1',
      taskId: tTaskId,
      startTime: DateTime.now(),
      endTime: null,
    );

    when(mockRepository.resumeTimer(tTaskId))
        .thenAnswer((_) async => Success(tTimeLog));

    // act
    final result = await usecase(const ResumeTimerParams(tTaskId));

    // assert
    expect(result, isA<Success<TimeLog>>());
    expect((result as Success<TimeLog>).value, tTimeLog);
    verify(mockRepository.resumeTimer(tTaskId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

