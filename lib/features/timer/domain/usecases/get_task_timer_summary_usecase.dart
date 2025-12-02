import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Parameters for the [GetTaskTimerSummaryUseCase].
class GetTaskTimerSummaryParams {
  /// The ID of the task to get the summary for.
  final String taskId;

  /// Creates [GetTaskTimerSummaryParams] with the given [taskId].
  const GetTaskTimerSummaryParams(this.taskId);
}

/// Use case for retrieving aggregated time tracking information for a task.
///
/// This use case returns a summary containing the total tracked time for
/// the specified task and whether there is currently an active timer.
/// This is useful for displaying time tracking statistics in the UI.
@lazySingleton
class GetTaskTimerSummaryUseCase
    implements UseCase<TaskTimerSummary, GetTaskTimerSummaryParams> {
  /// The repository to fetch timer summary from.
  final TimerRepository _repository;

  /// Creates a [GetTaskTimerSummaryUseCase] with the given [repository].
  GetTaskTimerSummaryUseCase(this._repository);

  @override
  Future<Result<TaskTimerSummary>> call(
    GetTaskTimerSummaryParams params,
  ) {
    return _repository.getTaskTimerSummary(params.taskId);
  }
}


