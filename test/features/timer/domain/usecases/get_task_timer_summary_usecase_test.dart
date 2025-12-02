import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_task_timer_summary_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/timer_repository_mock.mocks.dart';

void main() {
  late GetTaskTimerSummaryUseCase usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTimerRepository();
    usecase = GetTaskTimerSummaryUseCase(mockRepository);
  });

  test('should get timer summary for a task from repository', () async {
    // arrange
    const tTaskId = 'task-1';
    const tSummary = TaskTimerSummary(
      taskId: tTaskId,
      taskTitle: 'Test Task',
      totalTrackedSeconds: 7200, // 2 hours
      hasActiveTimer: false,
    );

    when(mockRepository.getTaskTimerSummary(tTaskId))
        .thenAnswer((_) async => Success(tSummary));

    // act
    final result = await usecase(const GetTaskTimerSummaryParams(tTaskId));

    // assert
    expect(result, isA<Success<TaskTimerSummary>>());
    expect((result as Success<TaskTimerSummary>).value, tSummary);
    verify(mockRepository.getTaskTimerSummary(tTaskId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

