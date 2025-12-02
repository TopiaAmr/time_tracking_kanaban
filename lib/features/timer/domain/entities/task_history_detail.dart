import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';

/// Detailed history information for a task including summary and all time logs.
class TaskHistoryDetail extends Equatable {
  final String taskId;
  final String taskTitle;
  final int totalTrackedSeconds;
  final bool hasActiveTimer;
  final List<TimeLog> timeLogs;

  const TaskHistoryDetail({
    required this.taskId,
    required this.taskTitle,
    required this.totalTrackedSeconds,
    required this.hasActiveTimer,
    required this.timeLogs,
  });

  Duration get totalTrackedDuration =>
      Duration(seconds: totalTrackedSeconds);

  @override
  List<Object?> get props => [
        taskId,
        taskTitle,
        totalTrackedSeconds,
        hasActiveTimer,
        timeLogs,
      ];
}
