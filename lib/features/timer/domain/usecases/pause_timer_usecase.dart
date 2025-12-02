import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Use case for pausing the currently active timer.
///
/// This use case pauses the active timer, if any. If no timer is active,
/// this will return a failure. The paused timer can be resumed later
/// using [ResumeTimerUseCase].
@lazySingleton
class PauseTimerUseCase implements UseCase<TimeLog, NoParams> {
  /// The repository to manage timer operations.
  final TimerRepository _repository;

  /// Creates a [PauseTimerUseCase] with the given [repository].
  PauseTimerUseCase(this._repository);

  @override
  Future<Result<TimeLog>> call(NoParams params) {
    return _repository.pauseTimer();
  }
}


