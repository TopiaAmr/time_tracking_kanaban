import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_completed_tasks_history_usecase.dart';

import '../../../../mocks/mock_setup.dart';
import '../../../../mocks/timer_repository_mock.mocks.dart';

void main() {
  late GetCompletedTasksHistoryUseCase usecase;
  late MockTimerRepository mockRepository;

  setUp(() {
    setupMockDummyValues();
    mockRepository = MockTimerRepository();
    usecase = GetCompletedTasksHistoryUseCase(mockRepository);
  });

  test('should get completed tasks history from repository', () async {
    // arrange
    final tHistory = [
      const TaskTimerSummary(
        taskId: 'task-1',
        taskTitle: 'Test Task 1',
        totalTrackedSeconds: 3600, // 1 hour
        hasActiveTimer: false,
      ),
      const TaskTimerSummary(
        taskId: 'task-2',
        taskTitle: 'Test Task 2',
        totalTrackedSeconds: 7200, // 2 hours
        hasActiveTimer: false,
      ),
    ];

    when(mockRepository.getCompletedTasksHistory())
        .thenAnswer((_) async => Success(tHistory));

    // act
    final result = await usecase(const NoParams());

    // assert
    expect(result, isA<Success<List<TaskTimerSummary>>>());
    expect((result as Success<List<TaskTimerSummary>>).value, tHistory);
    verify(mockRepository.getCompletedTasksHistory()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

