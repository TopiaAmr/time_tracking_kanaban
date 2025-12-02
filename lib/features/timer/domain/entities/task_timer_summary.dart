import 'package:equatable/equatable.dart';

/// Aggregated time tracking information for a single task.
class TaskTimerSummary extends Equatable {
  final String taskId;
  final int totalTrackedSeconds;
  final bool hasActiveTimer;

  const TaskTimerSummary({
    required this.taskId,
    required this.totalTrackedSeconds,
    required this.hasActiveTimer,
  });

  Duration get totalTrackedDuration =>
      Duration(seconds: totalTrackedSeconds);

  @override
  List<Object?> get props => [
        taskId,
        totalTrackedSeconds,
        hasActiveTimer,
      ];
}


