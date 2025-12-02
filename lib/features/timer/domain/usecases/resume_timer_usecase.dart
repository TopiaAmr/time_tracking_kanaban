import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Parameters for the [ResumeTimerUseCase].
class ResumeTimerParams {
  /// The ID of the task to resume the timer for.
  final String taskId;

  /// Creates [ResumeTimerParams] with the given [taskId].
  const ResumeTimerParams(this.taskId);
}

/// Use case for resuming a timer for a task.
///
/// This use case resumes a timer for the specified task. The implementation
/// may either create a new [TimeLog] entry or reopen a previously paused one,
/// depending on the persistence model used.
@lazySingleton
class ResumeTimerUseCase implements UseCase<TimeLog, ResumeTimerParams> {
  /// The repository to manage timer operations.
  final TimerRepository _repository;

  /// Creates a [ResumeTimerUseCase] with the given [repository].
  ResumeTimerUseCase(this._repository);

  @override
  Future<Result<TimeLog>> call(ResumeTimerParams params) {
    return _repository.resumeTimer(params.taskId);
  }
}
