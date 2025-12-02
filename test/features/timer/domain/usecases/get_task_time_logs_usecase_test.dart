import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_task_time_logs_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/timer_repository_mock.mocks.dart';

void main() {
  late GetTaskTimeLogsUseCase usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTimerRepository();
    usecase = GetTaskTimeLogsUseCase(mockRepository);
  });

  test('should get time logs for a task from repository', () async {
    // arrange
    const tTaskId = 'task-1';
    final tTimeLogs = [
      TimeLog(
        id: 'log-1',
        taskId: tTaskId,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      TimeLog(
        id: 'log-2',
        taskId: tTaskId,
        startTime: DateTime.now().subtract(const Duration(minutes: 30)),
        endTime: null,
      ),
    ];

    when(mockRepository.getTimeLogsForTask(tTaskId))
        .thenAnswer((_) async => Success(tTimeLogs));

    // act
    final result = await usecase(const GetTaskTimeLogsParams(tTaskId));

    // assert
    expect(result, isA<Success<List<TimeLog>>>());
    expect((result as Success<List<TimeLog>>).value, tTimeLogs);
    verify(mockRepository.getTimeLogsForTask(tTaskId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

