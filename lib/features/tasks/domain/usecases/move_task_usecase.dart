import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [MoveTask] use case.
class MoveTaskParams extends Equatable {
  /// The task to move.
  final Task task;
  
  /// The ID of the target project.
  final String projectId;
  
  /// The ID of the target section.
  final String sectionId;

  /// Creates [MoveTaskParams] with the given [task], [projectId], and [sectionId].
  const MoveTaskParams({
    required this.task,
    required this.projectId,
    required this.sectionId,
  });

  @override
  List<Object?> get props => [task, projectId, sectionId];
}

/// Use case for moving a task to a different project and/or section.
///
/// This use case moves a task from its current location to the specified
/// project and section. The moved task is returned.
@lazySingleton
class MoveTask implements UseCase<Task, MoveTaskParams> {
  /// The repository to perform the move operation.
  final TasksRepository repository;

  /// Creates a [MoveTask] use case with the given [repository].
  MoveTask(this.repository);

  @override
  Future<Result<Task>> call(MoveTaskParams params) async {
    return await repository.moveTask(params.task, params.projectId, params.sectionId);
  }
}

