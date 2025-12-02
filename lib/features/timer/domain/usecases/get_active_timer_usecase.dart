import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Use case for retrieving the currently active timer.
///
/// This use case returns the active timer, if any. Returns `null` if
/// no timer is currently active. This is useful for displaying the
/// current timer state in the UI.
@lazySingleton
class GetActiveTimerUseCase implements UseCase<TimeLog?, NoParams> {
  /// The repository to fetch timer information from.
  final TimerRepository _repository;

  /// Creates a [GetActiveTimerUseCase] with the given [repository].
  GetActiveTimerUseCase(this._repository);

  @override
  Future<Result<TimeLog?>> call(NoParams params) {
    return _repository.getActiveTimer();
  }
}


