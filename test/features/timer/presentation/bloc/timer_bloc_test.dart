import 'dart:async';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_active_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/pause_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/resume_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/start_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/stop_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_state.dart';

import '../../../../mocks/mock_setup.dart';
import 'timer_bloc_test.mocks.dart';

@GenerateMocks([
  StartTimerUseCase,
  PauseTimerUseCase,
  ResumeTimerUseCase,
  StopTimerUseCase,
  GetActiveTimerUseCase,
])
void main() {
  late TimerBloc timerBloc;
  late MockStartTimerUseCase mockStartTimerUseCase;
  late MockPauseTimerUseCase mockPauseTimerUseCase;
  late MockResumeTimerUseCase mockResumeTimerUseCase;
  late MockStopTimerUseCase mockStopTimerUseCase;
  late MockGetActiveTimerUseCase mockGetActiveTimerUseCase;

  final dummyDateTime = DateTime(2024, 1, 1, 12, 0, 0);

  TimeLog createTimeLog({
    required String id,
    required String taskId,
    required DateTime startTime,
    DateTime? endTime,
  }) {
    return TimeLog(
      id: id,
      taskId: taskId,
      startTime: startTime,
      endTime: endTime,
    );
  }

  setUp(() {
    setupMockDummyValues();
    mockStartTimerUseCase = MockStartTimerUseCase();
    mockPauseTimerUseCase = MockPauseTimerUseCase();
    mockResumeTimerUseCase = MockResumeTimerUseCase();
    mockStopTimerUseCase = MockStopTimerUseCase();
    mockGetActiveTimerUseCase = MockGetActiveTimerUseCase();

    timerBloc = TimerBloc(
      mockStartTimerUseCase,
      mockPauseTimerUseCase,
      mockResumeTimerUseCase,
      mockStopTimerUseCase,
      mockGetActiveTimerUseCase,
    );
  });

  tearDown(() {
    timerBloc.close();
  });

  group('TimerBloc', () {
    test('initial state is TimerInitial', () {
      expect(timerBloc.state, const TimerInitial());
    });

    blocTest<TimerBloc, TimerState>(
      'emits TimerRunning when StartTimer succeeds',
      build: () {
        final timeLog = createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime,
        );
        when(mockStartTimerUseCase(any)).thenAnswer(
          (_) async => Success(timeLog),
        );
        return timerBloc;
      },
      act: (bloc) => bloc.add(const StartTimer('task1')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunning>(),
      ],
      verify: (_) {
        verify(mockStartTimerUseCase(any)).called(1);
      },
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerError when StartTimer fails',
      build: () {
        when(mockStartTimerUseCase(any)).thenAnswer(
          (_) async => const Error<TimeLog>(ServerFailure()),
        );
        return timerBloc;
      },
      act: (bloc) => bloc.add(const StartTimer('task1')),
      expect: () => [
        const TimerError(ServerFailure()),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerPaused when PauseTimer succeeds',
      build: () {
        final timeLog = createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime.subtract(const Duration(seconds: 30)),
          endTime: dummyDateTime,
        );
        when(mockPauseTimerUseCase(any)).thenAnswer(
          (_) async => Success(timeLog),
        );
        return timerBloc;
      },
      seed: () => TimerRunning(
        timeLog: createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime.subtract(const Duration(seconds: 30)),
        ),
        elapsedSeconds: 30,
      ),
      act: (bloc) => bloc.add(const PauseTimer()),
      expect: () => [
        isA<TimerPaused>(),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerError when PauseTimer fails',
      build: () {
        when(mockPauseTimerUseCase(any)).thenAnswer(
          (_) async => const Error<TimeLog>(ServerFailure()),
        );
        return timerBloc;
      },
      seed: () => TimerRunning(
        timeLog: createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime,
        ),
        elapsedSeconds: 0,
      ),
      act: (bloc) => bloc.add(const PauseTimer()),
      expect: () => [
        const TimerError(ServerFailure()),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerRunning when ResumeTimer succeeds',
      build: () {
        final timeLog = createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime,
        );
        when(mockResumeTimerUseCase(any)).thenAnswer(
          (_) async => Success(timeLog),
        );
        return timerBloc;
      },
      act: (bloc) => bloc.add(const ResumeTimer('task1')),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunning>(),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerStopped when StopTimer succeeds',
      build: () {
        final timeLog = createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime.subtract(const Duration(seconds: 60)),
          endTime: dummyDateTime,
        );
        when(mockStopTimerUseCase(any)).thenAnswer(
          (_) async => Success(timeLog),
        );
        return timerBloc;
      },
      seed: () => TimerRunning(
        timeLog: createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime.subtract(const Duration(seconds: 60)),
        ),
        elapsedSeconds: 60,
      ),
      act: (bloc) => bloc.add(const StopTimer()),
      expect: () => [
        isA<TimerStopped>(),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerInitial when LoadActiveTimer finds no active timer',
      build: () {
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(null),
        );
        return timerBloc;
      },
      act: (bloc) => bloc.add(const LoadActiveTimer()),
      expect: () => [
        const TimerInitial(),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'emits TimerRunning when LoadActiveTimer finds active timer',
      build: () {
        final activeTimer = createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime.subtract(const Duration(seconds: 30)),
        );
        when(mockGetActiveTimerUseCase(any)).thenAnswer(
          (_) async => Success<TimeLog?>(activeTimer),
        );
        return timerBloc;
      },
      act: (bloc) => bloc.add(const LoadActiveTimer()),
      wait: const Duration(milliseconds: 100),
      expect: () => [
        isA<TimerRunning>(),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'updates elapsed time on TimerTick when timer is running',
      build: () => timerBloc,
      seed: () => TimerRunning(
        timeLog: createTimeLog(
          id: 'timer1',
          taskId: 'task1',
          startTime: dummyDateTime.subtract(const Duration(seconds: 5)),
        ),
        elapsedSeconds: 5,
      ),
      act: (bloc) {
        // Wait a bit to allow time to pass
        Future.delayed(const Duration(milliseconds: 100), () {
          bloc.add(const TimerTick());
        });
      },
      wait: const Duration(milliseconds: 200),
      expect: () => [
        isA<TimerRunning>(),
      ],
    );

    blocTest<TimerBloc, TimerState>(
      'does not update state on TimerTick when timer is not running',
      build: () => timerBloc,
      seed: () => const TimerInitial(),
      act: (bloc) => bloc.add(const TimerTick()),
      expect: () => [],
    );
  });
}

