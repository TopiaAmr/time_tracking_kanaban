import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_completed_tasks_history_usecase.dart';
import 'task_history_state.dart';

/// Cubit for managing task history state.
///
/// This cubit handles loading and displaying the history of completed
/// tasks with their tracked time summaries.
@injectable
class TaskHistoryCubit extends Cubit<TaskHistoryState> {
  /// Use case for getting completed tasks history.
  final GetCompletedTasksHistoryUseCase _getCompletedTasksHistoryUseCase;

  /// Creates a [TaskHistoryCubit] with the required use case.
  TaskHistoryCubit(this._getCompletedTasksHistoryUseCase)
      : super(const TaskHistoryInitial());

  /// Loads the history of completed tasks.
  Future<void> loadHistory() async {
    emit(const TaskHistoryLoading());

    final result = await _getCompletedTasksHistoryUseCase(NoParams());

    if (result is Error<List<TaskTimerSummary>>) {
      emit(TaskHistoryError(result.failure));
      return;
    }

    final summaries = (result as Success<List<TaskTimerSummary>>).value;
    emit(TaskHistoryLoaded(summaries));
  }
}

