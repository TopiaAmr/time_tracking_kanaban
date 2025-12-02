import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Parameters for the [GetTaskTimeLogsUseCase].
class GetTaskTimeLogsParams {
  /// The ID of the task to get time logs for.
  final String taskId;

  /// Creates [GetTaskTimeLogsParams] with the given [taskId].
  const GetTaskTimeLogsParams(this.taskId);
}

/// Use case for retrieving all time logs for a specific task.
///
/// This use case returns all time log entries associated with the specified
/// task, including both completed and active timers. This is useful for
/// displaying a detailed history of time tracking for a task.
@lazySingleton
class GetTaskTimeLogsUseCase
    implements UseCase<List<TimeLog>, GetTaskTimeLogsParams> {
  /// The repository to fetch time logs from.
  final TimerRepository _repository;

  /// Creates a [GetTaskTimeLogsUseCase] with the given [repository].
  GetTaskTimeLogsUseCase(this._repository);

  @override
  Future<Result<List<TimeLog>>> call(GetTaskTimeLogsParams params) {
    return _repository.getTimeLogsForTask(params.taskId);
  }
}


