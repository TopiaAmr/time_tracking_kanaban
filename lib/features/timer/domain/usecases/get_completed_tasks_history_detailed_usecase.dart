import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_history_detail.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Use case for retrieving detailed history of completed tasks with time logs.
///
/// This use case returns a list of detailed history for all completed tasks,
/// including all time log entries for each task. Intended for display in a
/// "Task History" view with expanded details.
@lazySingleton
class GetCompletedTasksHistoryDetailedUseCase
    implements UseCase<List<TaskHistoryDetail>, NoParams> {
  /// The repository to fetch task history from.
  final TimerRepository _repository;

  /// Creates a [GetCompletedTasksHistoryDetailedUseCase] with the given [repository].
  GetCompletedTasksHistoryDetailedUseCase(this._repository);

  @override
  Future<Result<List<TaskHistoryDetail>>> call(NoParams params) {
    return _repository.getCompletedTasksHistoryDetailed();
  }
}
