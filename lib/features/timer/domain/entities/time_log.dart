import 'package:equatable/equatable.dart';

/// Domain entity representing a single time log entry for a task.
///
/// A time log can be:
/// - **Active**: `endTime` is `null` (timer is currently running).
/// - **Completed**: `endTime` is non-null (finished interval).
class TimeLog extends Equatable {
  final String id;
  final String taskId;
  final DateTime startTime;
  final DateTime? endTime;

  const TimeLog({
    required this.id,
    required this.taskId,
    required this.startTime,
    this.endTime,
  });

  /// Returns the duration in seconds for this log.
  ///
  /// If the log is still active (`endTime == null`), the duration is computed
  /// using the provided [now] value.
  int durationSeconds(DateTime now) {
    final effectiveEnd = endTime ?? now;
    return effectiveEnd.difference(startTime).inSeconds;
  }

  bool get isActive => endTime == null;

  @override
  List<Object?> get props => [
        id,
        taskId,
        startTime,
        endTime,
      ];
}


