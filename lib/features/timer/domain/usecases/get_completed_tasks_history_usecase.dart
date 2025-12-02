import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Use case for retrieving the history of completed tasks with their tracked time.
///
/// This use case returns a list of timer summaries for all completed tasks,
/// intended for display in a "Task History" view. Each summary contains
/// the total tracked time for the task.
@lazySingleton
class GetCompletedTasksHistoryUseCase
    implements UseCase<List<TaskTimerSummary>, NoParams> {
  /// The repository to fetch task history from.
  final TimerRepository _repository;

  /// Creates a [GetCompletedTasksHistoryUseCase] with the given [repository].
  GetCompletedTasksHistoryUseCase(this._repository);

  @override
  Future<Result<List<TaskTimerSummary>>> call(NoParams params) {
    return _repository.getCompletedTasksHistory();
  }
}


