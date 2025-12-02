import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [UpdateTask] use case.
class UpdateTaskParams extends Equatable {
  /// The task with updated information.
  final Task task;

  /// Creates [UpdateTaskParams] with the given [task].
  const UpdateTaskParams(this.task);

  @override
  List<Object?> get props => [task];
}

/// Use case for updating an existing task.
///
/// This use case updates a task in the system using the task information
/// provided in the parameters. The updated task is returned.
@lazySingleton
class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  /// The repository to update the task in.
  final TasksRepository repository;

  /// Creates an [UpdateTask] use case with the given [repository].
  UpdateTask(this.repository);

  @override
  Future<Result<Task>> call(UpdateTaskParams params) async {
    return await repository.updateTask(params.task);
  }
}

