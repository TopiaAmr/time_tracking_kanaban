import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [AddTask] use case.
class AddTaskParams extends Equatable {
  /// The task to create.
  final Task task;

  /// Creates [AddTaskParams] with the given [task].
  const AddTaskParams(this.task);

  @override
  List<Object?> get props => [task];
}

/// Use case for creating a new task.
///
/// This use case creates a new task in the system using the task
/// information provided in the parameters. The created task is returned
/// with its assigned ID.
@lazySingleton
class AddTask implements UseCase<Task, AddTaskParams> {
  /// The repository to create the task in.
  final TasksRepository repository;

  /// Creates an [AddTask] use case with the given [repository].
  AddTask(this.repository);

  @override
  Future<Result<Task>> call(AddTaskParams params) async {
    return await repository.createTask(params.task);
  }
}
