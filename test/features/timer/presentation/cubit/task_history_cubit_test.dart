import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_completed_tasks_history_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_completed_tasks_history_detailed_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/cubit/task_history_cubit.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/cubit/task_history_state.dart';

import '../../../../mocks/mock_setup.dart';
import 'task_history_cubit_test.mocks.dart';

@GenerateMocks([
  GetCompletedTasksHistoryUseCase,
  GetCompletedTasksHistoryDetailedUseCase,
])
void main() {
  late TaskHistoryCubit taskHistoryCubit;
  late MockGetCompletedTasksHistoryUseCase mockGetCompletedTasksHistoryUseCase;
  late MockGetCompletedTasksHistoryDetailedUseCase mockGetCompletedTasksHistoryDetailedUseCase;

  setUp(() {
    setupMockDummyValues();
    mockGetCompletedTasksHistoryUseCase = MockGetCompletedTasksHistoryUseCase();
    mockGetCompletedTasksHistoryDetailedUseCase = MockGetCompletedTasksHistoryDetailedUseCase();
    taskHistoryCubit = TaskHistoryCubit(
      mockGetCompletedTasksHistoryUseCase,
      mockGetCompletedTasksHistoryDetailedUseCase,
    );
  });

  tearDown(() {
    taskHistoryCubit.close();
  });

  group('TaskHistoryCubit', () {
    test('initial state is TaskHistoryInitial', () {
      expect(taskHistoryCubit.state, const TaskHistoryInitial());
    });

    blocTest<TaskHistoryCubit, TaskHistoryState>(
      'emits [TaskHistoryLoading, TaskHistoryLoaded] when loadHistory succeeds',
      build: () {
        final summaries = [
          const TaskTimerSummary(
            taskId: 'task1',
        taskTitle: 'Test Task 1',
            totalTrackedSeconds: 3600,
            hasActiveTimer: false,
          ),
          const TaskTimerSummary(
            taskId: 'task2',
        taskTitle: 'Test Task 2',
            totalTrackedSeconds: 1800,
            hasActiveTimer: false,
          ),
        ];
        when(mockGetCompletedTasksHistoryUseCase(any)).thenAnswer(
          (_) async => Success(summaries),
        );
        return taskHistoryCubit;
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const TaskHistoryLoading(),
        TaskHistoryLoaded([
          const TaskTimerSummary(
            taskId: 'task1',
        taskTitle: 'Test Task 1',
            totalTrackedSeconds: 3600,
            hasActiveTimer: false,
          ),
          const TaskTimerSummary(
            taskId: 'task2',
        taskTitle: 'Test Task 2',
            totalTrackedSeconds: 1800,
            hasActiveTimer: false,
          ),
        ]),
      ],
      verify: (_) {
        verify(mockGetCompletedTasksHistoryUseCase(any)).called(1);
      },
    );

    blocTest<TaskHistoryCubit, TaskHistoryState>(
      'emits [TaskHistoryLoading, TaskHistoryError] when loadHistory fails',
      build: () {
        when(mockGetCompletedTasksHistoryUseCase(any)).thenAnswer(
          (_) async => const Error<List<TaskTimerSummary>>(ServerFailure()),
        );
        return taskHistoryCubit;
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const TaskHistoryLoading(),
        const TaskHistoryError(ServerFailure()),
      ],
    );

    blocTest<TaskHistoryCubit, TaskHistoryState>(
      'emits TaskHistoryLoaded with empty list when no history exists',
      build: () {
        when(mockGetCompletedTasksHistoryUseCase(any)).thenAnswer(
          (_) async => const Success<List<TaskTimerSummary>>([]),
        );
        return taskHistoryCubit;
      },
      act: (cubit) => cubit.loadHistory(),
      expect: () => [
        const TaskHistoryLoading(),
        const TaskHistoryLoaded([]),
      ],
    );
  });
}

