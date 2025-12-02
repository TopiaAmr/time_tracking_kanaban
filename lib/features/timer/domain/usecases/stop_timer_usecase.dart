import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Use case for stopping the currently active timer.
///
/// This use case stops the active timer, if any, and finalizes the time log
/// entry. If no timer is active, this will return a failure. Once stopped,
/// the timer cannot be resumed and a new timer must be started.
@lazySingleton
class StopTimerUseCase implements UseCase<TimeLog, NoParams> {
  /// The repository to manage timer operations.
  final TimerRepository _repository;

  /// Creates a [StopTimerUseCase] with the given [repository].
  StopTimerUseCase(this._repository);

  @override
  Future<Result<TimeLog>> call(NoParams params) {
    return _repository.stopTimer();
  }
}


