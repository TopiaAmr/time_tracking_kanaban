import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [DeleteTaskUseCase] use case.
class DeleteTaskParams extends Equatable {
  /// The ID of the task to delete.
  final String taskId;

  /// Creates [DeleteTaskParams] with the given [taskId].
  const DeleteTaskParams(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Use case for deleting a task.
///
/// This use case deletes a task from the system using the task ID
/// provided in the parameters.
@lazySingleton
class DeleteTaskUseCase implements UseCase<void, DeleteTaskParams> {
  /// The repository to delete the task from.
  final TasksRepository repository;

  /// Creates a [DeleteTaskUseCase] use case with the given [repository].
  DeleteTaskUseCase(this.repository);

  @override
  Future<Result<void>> call(DeleteTaskParams params) async {
    return await repository.deleteTask(params.taskId);
  }
}

