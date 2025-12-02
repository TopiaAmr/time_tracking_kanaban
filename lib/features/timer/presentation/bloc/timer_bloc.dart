import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_active_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/pause_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/resume_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/start_timer_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/stop_timer_usecase.dart';
import 'timer_event.dart';
import 'timer_state.dart';

/// BLoC for managing timer state with real-time updates.
///
/// This BLoC handles starting, pausing, resuming, and stopping timers.
/// It uses a Ticker to provide real-time updates of elapsed time every second.
@lazySingleton
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  /// Use case for starting a timer.
  final StartTimerUseCase _startTimerUseCase;

  /// Use case for pausing a timer.
  final PauseTimerUseCase _pauseTimerUseCase;

  /// Use case for resuming a timer.
  final ResumeTimerUseCase _resumeTimerUseCase;

  /// Use case for stopping a timer.
  final StopTimerUseCase _stopTimerUseCase;

  /// Use case for getting the active timer.
  final GetActiveTimerUseCase _getActiveTimerUseCase;

  /// Ticker for timer updates.
  StreamSubscription<int>? _tickerSubscription;

  /// Creates a [TimerBloc] with the required use cases.
  TimerBloc(
    this._startTimerUseCase,
    this._pauseTimerUseCase,
    this._resumeTimerUseCase,
    this._stopTimerUseCase,
    this._getActiveTimerUseCase,
  ) : super(const TimerInitial()) {
    on<StartTimer>(_onStartTimer);
    on<PauseTimer>(_onPauseTimer);
    on<ResumeTimer>(_onResumeTimer);
    on<StopTimer>(_onStopTimer);
    on<TimerTick>(_onTimerTick);
    on<LoadActiveTimer>(_onLoadActiveTimer);
  }

  /// Handles the [StartTimer] event.
  Future<void> _onStartTimer(StartTimer event, Emitter<TimerState> emit) async {
    // Stop any existing ticker
    await _tickerSubscription?.cancel();
    _tickerSubscription = null;

    final result = await _startTimerUseCase(StartTimerParams(event.taskId));

    if (result is Error<TimeLog>) {
      emit(TimerError(result.failure));
      return;
    }

    final timeLog = (result as Success<TimeLog>).value;
    _startTicker(timeLog, emit);
  }

  /// Handles the [PauseTimer] event.
  Future<void> _onPauseTimer(PauseTimer event, Emitter<TimerState> emit) async {
    // Stop the ticker
    await _tickerSubscription?.cancel();
    _tickerSubscription = null;

    final result = await _pauseTimerUseCase(NoParams());

    if (result is Error<TimeLog>) {
      emit(TimerError(result.failure));
      return;
    }

    final timeLog = (result as Success<TimeLog>).value;
    final elapsedSeconds = _calculateElapsedSeconds(timeLog);
    emit(TimerPaused(timeLog: timeLog, elapsedSeconds: elapsedSeconds));
  }

  /// Handles the [ResumeTimer] event.
  Future<void> _onResumeTimer(
    ResumeTimer event,
    Emitter<TimerState> emit,
  ) async {
    // Stop any existing ticker
    await _tickerSubscription?.cancel();
    _tickerSubscription = null;

    final result = await _resumeTimerUseCase(ResumeTimerParams(event.taskId));

    if (result is Error<TimeLog>) {
      emit(TimerError(result.failure));
      return;
    }

    final timeLog = (result as Success<TimeLog>).value;
    _startTicker(timeLog, emit);
  }

  /// Handles the [StopTimer] event.
  Future<void> _onStopTimer(StopTimer event, Emitter<TimerState> emit) async {
    // Stop the ticker
    await _tickerSubscription?.cancel();
    _tickerSubscription = null;

    final result = await _stopTimerUseCase(NoParams());

    if (result is Error<TimeLog>) {
      emit(TimerError(result.failure));
      return;
    }

    final timeLog = (result as Success<TimeLog>).value;
    final elapsedSeconds = _calculateElapsedSeconds(timeLog);
    emit(TimerStopped(timeLog: timeLog, elapsedSeconds: elapsedSeconds));
  }

  /// Handles the [TimerTick] event.
  void _onTimerTick(TimerTick event, Emitter<TimerState> emit) {
    final currentState = state;
    if (currentState is TimerRunning) {
      final elapsedSeconds = _calculateElapsedSeconds(currentState.timeLog);
      emit(
        TimerRunning(
          timeLog: currentState.timeLog,
          elapsedSeconds: elapsedSeconds,
        ),
      );
    }
  }

  /// Handles the [LoadActiveTimer] event.
  Future<void> _onLoadActiveTimer(
    LoadActiveTimer event,
    Emitter<TimerState> emit,
  ) async {
    final result = await _getActiveTimerUseCase(NoParams());

    if (result is Error<TimeLog?>) {
      emit(TimerError(result.failure));
      return;
    }

    final activeTimer = (result as Success<TimeLog?>).value;

    if (activeTimer != null && activeTimer.isActive) {
      // Resume the active timer
      _startTicker(activeTimer, emit);
    } else {
      emit(const TimerInitial());
    }
  }

  /// Starts the ticker for real-time timer updates.
  void _startTicker(TimeLog timeLog, Emitter<TimerState> emit) {
    // Cancel any existing ticker
    _tickerSubscription?.cancel();

    // Calculate initial elapsed time
    final initialElapsedSeconds = _calculateElapsedSeconds(timeLog);
    emit(TimerRunning(timeLog: timeLog, elapsedSeconds: initialElapsedSeconds));

    // Start ticker for 1-second updates
    _tickerSubscription =
        Stream.periodic(const Duration(seconds: 1), (count) => count).listen((
          _,
        ) {
          add(const TimerTick());
        });
  }

  /// Calculates the elapsed time in seconds for a time log.
  int _calculateElapsedSeconds(TimeLog timeLog) {
    final now = DateTime.now();
    return timeLog.durationSeconds(now);
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }
}
