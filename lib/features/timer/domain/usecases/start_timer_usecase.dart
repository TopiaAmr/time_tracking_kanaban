import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Parameters for the [StartTimerUseCase].
class StartTimerParams {
  /// The ID of the task to start the timer for.
  final String taskId;

  /// Creates [StartTimerParams] with the given [taskId].
  const StartTimerParams(this.taskId);
}

/// Use case for starting a timer for a task.
///
/// This use case starts a new timer for the specified task. If there is
/// already an active timer, it will be stopped before starting the new one.
/// The timer state is persisted so it survives app restarts.
@lazySingleton
class StartTimerUseCase implements UseCase<TimeLog, StartTimerParams> {
  /// The repository to manage timer operations.
  final TimerRepository _repository;

  /// Creates a [StartTimerUseCase] with the given [repository].
  StartTimerUseCase(this._repository);

  @override
  Future<Result<TimeLog>> call(StartTimerParams params) {
    return _repository.startTimer(params.taskId);
  }
}


