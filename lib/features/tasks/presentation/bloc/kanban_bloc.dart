import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/close_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/delete_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_sections_usecase.dart'
    show GetSections, GetSectionsParams;
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_tasks_usecase.dart'
    show GetTasksParams, GetTasksUseCase;
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/move_task_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_task_usecase.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'kanban_event.dart';
import 'kanban_state.dart';

/// BLoC for managing Kanban board state.
///
/// This BLoC handles loading tasks, grouping them into columns (To Do,
/// In Progress, Done), and managing task operations like creating,
/// updating, moving, and closing tasks.
@lazySingleton
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

  /// Use case for deleting a task.
  final DeleteTaskUseCase _deleteTask;

  /// Use case for getting all sections.
  final GetSections _getSections;

  /// Timer BLoC for auto-stopping timer when task is completed.
  final TimerBloc _timerBloc;

  /// Creates a [KanbanBloc] with the required use cases.
  KanbanBloc(
    this._getTasks,
    this._moveTask,
    this._addTask,
    this._updateTask,
    this._closeTask,
    this._deleteTask,
    this._getSections,
    this._timerBloc,
  ) : super(const KanbanInitial()) {
    on<LoadKanbanTasks>(_onLoadKanbanTasks);
    on<MoveTaskEvent>(_onMoveTask);
    on<CreateTask>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<CloseTaskEvent>(_onCloseTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  /// Handles the [LoadKanbanTasks] event.
  Future<void> _onLoadKanbanTasks(
    LoadKanbanTasks event,
    Emitter<KanbanState> emit,
  ) async {
    developer.log(
      '📥 LoadKanbanTasks event received (forceRefresh: ${event.forceRefresh})',
      name: 'KanbanBloc',
    );
    
    // Only show loading if we don't already have loaded data
    if (state is! KanbanLoaded) {
      emit(const KanbanLoading());
    }

    final tasksResult = await _getTasks(
      GetTasksParams(forceRefresh: event.forceRefresh),
    );
    final sectionsResult = await _getSections(
      GetSectionsParams(forceRefresh: event.forceRefresh),
    );
    
    developer.log(
      '📊 Fetched ${tasksResult is Success ? (tasksResult as Success).value.length : 0} tasks',
      name: 'KanbanBloc',
    );

    if (tasksResult is Error<List<Task>>) {
      // Only emit error if we don't have existing data to show
      if (state is! KanbanLoaded) {
        emit(KanbanError(tasksResult.failure));
      }
      return;
    }

    final tasks = (tasksResult as Success<List<Task>>).value;
    final sections = sectionsResult is Success<List<Section>>
        ? sectionsResult.value
        : <Section>[];

    final groupedTasks = _groupTasksBySections(tasks, sections);
    emit(
      KanbanLoaded(
        tasksBySection: groupedTasks['bySection'] as Map<String, List<Task>>,
        tasksWithoutSection: groupedTasks['withoutSection'] as List<Task>,
        sections: sections,
      ),
    );
  }

  /// Handles the [MoveTaskEvent] event.
  Future<void> _onMoveTask(
    MoveTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    // Don't emit loading state - we want instant feedback
    // Update local database first (offline-first approach)
    final result = await _moveTask(
      MoveTaskParams(
        task: event.task,
        projectId: event.projectId,
        sectionId: event.sectionId,
      ),
    );

    if (result is Error<Task>) {
      // Only show error if local update fails
      emit(KanbanError(result.failure));
      return;
    }

    // Optimistically update the state immediately from current state
    if (state is KanbanLoaded) {
      final currentState = state as KanbanLoaded;
      final updatedTask = (result as Success<Task>).value;

      // Deep copy the map - copy both map and lists inside
      final updatedTasksBySection = <String, List<Task>>{};
      currentState.tasksBySection.forEach((key, value) {
        updatedTasksBySection[key] = List<Task>.from(value);
      });
      
      final updatedTasksWithoutSection = List<Task>.from(
        currentState.tasksWithoutSection,
      );

      // Remove task from old location
      if (event.task.sectionId.isNotEmpty &&
          updatedTasksBySection.containsKey(event.task.sectionId)) {
        final sectionId = event.task.sectionId;
        updatedTasksBySection[sectionId] = updatedTasksBySection[sectionId]!
            .where((t) => t.id != event.task.id)
            .toList();
      } else {
        updatedTasksWithoutSection.removeWhere((t) => t.id == event.task.id);
      }

      // Add task to new location
      if (updatedTask.sectionId.isNotEmpty) {
        if (updatedTasksBySection.containsKey(updatedTask.sectionId)) {
          updatedTasksBySection[updatedTask.sectionId]!.add(updatedTask);
        } else {
          updatedTasksBySection[updatedTask.sectionId] = [updatedTask];
        }
      } else {
        updatedTasksWithoutSection.add(updatedTask);
      }

      // Emit updated state immediately (no loading indicator)
      emit(
        KanbanLoaded(
          tasksBySection: updatedTasksBySection,
          tasksWithoutSection: updatedTasksWithoutSection,
          sections: currentState.sections,
        ),
      );
    } else {
      // If not in loaded state, reload tasks
      add(const LoadKanbanTasks());
    }
    // Note: API sync happens in background via repository
    // The optimistic update above provides instant feedback
  }

  /// Handles the [CreateTask] event.
  Future<void> _onCreateTask(
    CreateTask event,
    Emitter<KanbanState> emit,
  ) async {
    // Don't emit loading state - update optimistically
    final result = await _addTask(AddTaskParams(event.task));

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Optimistically add task to current state
    if (state is KanbanLoaded) {
      final currentState = state as KanbanLoaded;
      final newTask = (result as Success<Task>).value;

      // Deep copy the map - copy both map and lists inside
      final updatedTasksBySection = <String, List<Task>>{};
      currentState.tasksBySection.forEach((key, value) {
        updatedTasksBySection[key] = List<Task>.from(value);
      });
      
      final updatedTasksWithoutSection = List<Task>.from(
        currentState.tasksWithoutSection,
      );

      // Add task to appropriate location
      if (newTask.sectionId.isNotEmpty) {
        if (updatedTasksBySection.containsKey(newTask.sectionId)) {
          updatedTasksBySection[newTask.sectionId]!.add(newTask);
        } else {
          updatedTasksBySection[newTask.sectionId] = [newTask];
        }
      } else {
        updatedTasksWithoutSection.add(newTask);
      }

      emit(
        KanbanLoaded(
          tasksBySection: updatedTasksBySection,
          tasksWithoutSection: updatedTasksWithoutSection,
          sections: currentState.sections,
        ),
      );
    } else {
      // If not in loaded state, reload tasks
      add(const LoadKanbanTasks());
    }
  }

  /// Handles the [UpdateTaskEvent] event.
  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    // Don't emit loading state - update optimistically
    final result = await _updateTask(UpdateTaskParams(event.task));

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Optimistically update task in current state
    if (state is KanbanLoaded) {
      final currentState = state as KanbanLoaded;
      final updatedTask = (result as Success<Task>).value;

      // Deep copy the map - copy both map and lists inside
      final updatedTasksBySection = <String, List<Task>>{};
      currentState.tasksBySection.forEach((key, value) {
        updatedTasksBySection[key] = List<Task>.from(value);
      });
      
      final updatedTasksWithoutSection = List<Task>.from(
        currentState.tasksWithoutSection,
      );

      // Update task in its current location
      bool found = false;
      if (updatedTask.sectionId.isNotEmpty &&
          updatedTasksBySection.containsKey(updatedTask.sectionId)) {
        final index = updatedTasksBySection[updatedTask.sectionId]!.indexWhere(
          (t) => t.id == updatedTask.id,
        );
        if (index != -1) {
          updatedTasksBySection[updatedTask.sectionId]![index] = updatedTask;
          found = true;
        }
      } else {
        final index = updatedTasksWithoutSection.indexWhere(
          (t) => t.id == updatedTask.id,
        );
        if (index != -1) {
          updatedTasksWithoutSection[index] = updatedTask;
          found = true;
        }
      }

      if (found) {
        emit(
          KanbanLoaded(
            tasksBySection: updatedTasksBySection,
            tasksWithoutSection: updatedTasksWithoutSection,
            sections: currentState.sections,
          ),
        );
      } else {
        // Task not found, reload
        add(const LoadKanbanTasks());
      }
    } else {
      // If not in loaded state, reload tasks
      add(const LoadKanbanTasks());
    }
  }

  /// Handles the [CloseTaskEvent] event.
  Future<void> _onCloseTask(
    CloseTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    // Auto-stop timer if running for this task (per spec requirement)
    _timerBloc.add(StopTimerForTask(event.task.id));

    // Don't emit loading state - update optimistically
    final result = await _closeTask(CloseTaskParams(event.task));

    if (result is Error<Task>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Optimistically remove task from current state (closed tasks are typically hidden)
    if (state is KanbanLoaded) {
      final currentState = state as KanbanLoaded;

      // Deep copy the map - copy both map and lists inside
      final updatedTasksBySection = <String, List<Task>>{};
      currentState.tasksBySection.forEach((key, value) {
        updatedTasksBySection[key] = List<Task>.from(value);
      });
      
      final updatedTasksWithoutSection = List<Task>.from(
        currentState.tasksWithoutSection,
      );

      // Remove task from its location
      bool removed = false;
      if (event.task.sectionId.isNotEmpty &&
          updatedTasksBySection.containsKey(event.task.sectionId)) {
        final sectionId = event.task.sectionId;
        updatedTasksBySection[sectionId] = updatedTasksBySection[sectionId]!
            .where((t) => t.id != event.task.id)
            .toList();
        removed = true;
      } else {
        updatedTasksWithoutSection.removeWhere((t) => t.id == event.task.id);
        removed = true;
      }

      if (removed) {
        emit(
          KanbanLoaded(
            tasksBySection: updatedTasksBySection,
            tasksWithoutSection: updatedTasksWithoutSection,
            sections: currentState.sections,
          ),
        );
      } else {
        // Task not found, reload
        add(const LoadKanbanTasks());
      }
    } else {
      // If not in loaded state, reload tasks
      add(const LoadKanbanTasks());
    }
  }

  /// Handles the [DeleteTaskEvent] event.
  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<KanbanState> emit,
  ) async {
    final result = await _deleteTask(DeleteTaskParams(event.taskId));

    if (result is Error<void>) {
      emit(KanbanError(result.failure));
      return;
    }

    // Optimistically remove task from current state
    if (state is KanbanLoaded) {
      final currentState = state as KanbanLoaded;

      // Deep copy the map - copy both map and lists inside
      final updatedTasksBySection = <String, List<Task>>{};
      currentState.tasksBySection.forEach((key, value) {
        updatedTasksBySection[key] = List<Task>.from(value);
      });
      
      final updatedTasksWithoutSection = List<Task>.from(
        currentState.tasksWithoutSection,
      );

      // Remove task from its location
      bool removed = false;
      for (final sectionId in updatedTasksBySection.keys) {
        final beforeLength = updatedTasksBySection[sectionId]!.length;
        updatedTasksBySection[sectionId] = updatedTasksBySection[sectionId]!
            .where((t) => t.id != event.taskId)
            .toList();
        if (updatedTasksBySection[sectionId]!.length < beforeLength) {
          removed = true;
          break;
        }
      }

      if (!removed) {
        final beforeLength = updatedTasksWithoutSection.length;
        updatedTasksWithoutSection.removeWhere((t) => t.id == event.taskId);
        removed = updatedTasksWithoutSection.length < beforeLength;
      }

      if (removed) {
        emit(
          KanbanLoaded(
            tasksBySection: updatedTasksBySection,
            tasksWithoutSection: updatedTasksWithoutSection,
            sections: currentState.sections,
          ),
        );
      } else {
        // Task not found, reload
        add(const LoadKanbanTasks());
      }
    } else {
      // If not in loaded state, reload tasks
      add(const LoadKanbanTasks());
    }
  }

  /// Groups tasks by sections.
  ///
  /// Returns a map with keys: 'bySection' (Map&lt;String, List&lt;Task&gt;&gt;) and 'withoutSection' (List&lt;Task&gt;)
  Map<String, dynamic> _groupTasksBySections(
    List<Task> tasks,
    List<Section> sections,
  ) {
    final tasksBySection = <String, List<Task>>{};
    final tasksWithoutSection = <Task>[];

    // Create a set of valid section IDs
    final validSectionIds = {for (final section in sections) section.id};

    for (final task in tasks) {
      if (task.sectionId.isEmpty || !validSectionIds.contains(task.sectionId)) {
        tasksWithoutSection.add(task);
      } else {
        tasksBySection.putIfAbsent(task.sectionId, () => []).add(task);
      }
    }

    return {'bySection': tasksBySection, 'withoutSection': tasksWithoutSection};
  }
}
