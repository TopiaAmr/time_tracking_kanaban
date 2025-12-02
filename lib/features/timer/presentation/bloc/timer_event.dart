import 'package:equatable/equatable.dart';

/// Base class for timer events.
abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to start a timer for a task.
class StartTimer extends TimerEvent {
  /// The ID of the task to start the timer for.
  final String taskId;

  const StartTimer(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Event to pause the active timer.
class PauseTimer extends TimerEvent {
  const PauseTimer();
}

/// Event to resume a paused timer.
class ResumeTimer extends TimerEvent {
  /// The ID of the task to resume the timer for.
  final String taskId;

  const ResumeTimer(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Event to stop the active timer.
class StopTimer extends TimerEvent {
  const StopTimer();
}

/// Internal event for timer tick updates.
///
/// This event is triggered by the Ticker to update the elapsed time
/// every second when the timer is running.
class TimerTick extends TimerEvent {
  const TimerTick();
}

/// Event to load the active timer on app start.
///
/// This event checks if there's an active timer persisted in storage
/// and resumes it if found.
class LoadActiveTimer extends TimerEvent {
  const LoadActiveTimer();
}

