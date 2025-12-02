import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/close_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_tasks_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/move_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/usecases/get_active_timer_usecase.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

/// BLoC for managing Kanban board state.
///
/// This BLoC handles loading tasks, grouping them into columns (To Do,
/// In Progress, Done), and managing task operations like creating,
/// updating, moving, and closing tasks.
@injectable
class KanbanBloc extends Bloc<KanbanEvent, KanbanState> {
  /// Use case for getting all tasks.
  final GetTasksUseCase _getTasks;

  /// Use case for moving a task.
  final MoveTaskUseCase _moveTask;

  /// Use case for creating a task.
  final AddTaskUseCase _addTask;

  /// Use case for updating a task.
  final UpdateTaskUseCase _updateTask;

  /// Use case for closing a task.
  final CloseTaskUseCase _closeTask;

  /// Use case for getting the active timer.
  final GetActiveTimerUseCase _getActiveTimer;

  /// Creates a [KanbanBloc] with the required use cases.
  KanbanBloc(
    this._getTasks,
    this._moveTask,
    this._addTask,
    this._updateTask,
    this._closeTask,
    this._getActiveTimer,
  ) : super(const KanbanInitial()) {
    on<LoadKanbanTasks>(_onLoadKanbanTasks);
    on<MoveTaskEvent>(_onMoveTask);
    on<CreateTask>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<CloseTaskEvent>(_onCloseTask);
  }

  /// Handles the [LoadKanbanTasks] event.
  Future<void> _onLoadKanbanTasks(
    LoadKanbanTasks event,
    Emitter<KanbanState> emit,
  ) async {
    emit(const KanbanLoading());

    final tasksResult = await _getTasks(NoParams());
    final activeTimerResult = await _getActiveTimer(NoParams());

    if (tasksResult is Error<List<Task>>) {
      emit(KanbanError(tasksResult.failure));
      return;
    }

    final tasks = (tasksResult as Success<List<Task>>).value;
    final activeTimer = activeTimerResult is Success<TimeLog?>
        ? activeTimerResult.value
        : null;

    final groupedTasks = _groupTasksIntoColumns(tasks, activeTimer);
    emit(
      KanbanLoaded(
        toDoTasks: groupedTasks['toDo'] ?? [],
        inProgressTasks: groupedTasks['inProgress'] ?? [],
        doneTasks: groupedTasks['done'] ?? [],
      ),
    );
  }

  /// Handles the [MoveTaskEvent] event.
  Future<void> _onMoveTask(
    MoveTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    emit(const KanbanLoading());

    final result = await _moveTask(
      MoveTaskParams(
        task: event.task,
        projectId: event.projectId,
        sectionId: event.sectionId,
      ),
    );

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Reload tasks after moving
    add(const LoadKanbanTasks());
  }

  /// Handles the [CreateTask] event.
  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<KanbanState> emit,
  ) async {
    emit(const KanbanLoading());

    final result = await _addTask(AddTaskParams(event.task));

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Reload tasks after creating
    add(const LoadKanbanTasks());
  }

  /// Handles the [UpdateTaskEvent] event.
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    emit(const KanbanLoading());

    final result = await _updateTask(UpdateTaskParams(event.task));

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Reload tasks after updating
    add(const LoadKanbanTasks());
  }

  /// Handles the [CloseTaskEvent] event.
  Future<void> _onCloseTask(
    CloseTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    emit(const KanbanLoading());

    final result = await _closeTask(CloseTaskParams(event.task));

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Reload tasks after closing
    add(const LoadKanbanTasks());
  }

  /// Groups tasks into Kanban columns based on their status and active timer.
  ///
  /// Returns a map with keys: 'toDo', 'inProgress', 'done'
  Map<String, List<Task>> _groupTasksIntoColumns(
    List<Task> tasks,
    TimeLog? activeTimer,
  ) {
    final toDo = <Task>[];
    final inProgress = <Task>[];
    final done = <Task>[];

    final activeTaskId = activeTimer?.taskId;

    for (final task in tasks) {
      if (task.checked) {
        // Task is completed -> Done column
        done.add(task);
      } else if (activeTaskId != null && task.id == activeTaskId) {
        // Task has active timer -> In Progress column
        inProgress.add(task);
      } else {
        // Task is not completed and has no active timer -> To Do column
        toDo.add(task);
      }
    }

    return {'toDo': toDo, 'inProgress': inProgress, 'done': done};
  }
}
