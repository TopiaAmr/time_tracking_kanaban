import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

/// Base class for timer states.
abstract class TimerState extends Equatable {
  const TimerState();

  @override
  List<Object?> get props => [];
}

/// Initial state when no timer is active.
class TimerInitial extends TimerState {
  const TimerInitial();
}

/// State when the timer is running.
class TimerRunning extends TimerState {
  /// The active time log.
  final TimeLog timeLog;

  /// The elapsed time in seconds.
  final int elapsedSeconds;

  const TimerRunning({
    required this.timeLog,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [timeLog, elapsedSeconds];
}

/// State when the timer is paused.
class TimerPaused extends TimerState {
  /// The paused time log.
  final TimeLog timeLog;

  /// The elapsed time in seconds when paused.
  final int elapsedSeconds;

  const TimerPaused({
    required this.timeLog,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [timeLog, elapsedSeconds];
}

/// State when the timer has been stopped.
class TimerStopped extends TimerState {
  /// The stopped time log.
  final TimeLog timeLog;

  /// The final elapsed time in seconds.
  final int elapsedSeconds;

  const TimerStopped({
    required this.timeLog,
    required this.elapsedSeconds,
  });

  @override
  List<Object?> get props => [timeLog, elapsedSeconds];
}

/// State when an error occurs.
class TimerError extends TimerState {
  /// The failure that occurred.
  final Failure failure;

  const TimerError(this.failure);

  @override
  List<Object?> get props => [failure];
}

