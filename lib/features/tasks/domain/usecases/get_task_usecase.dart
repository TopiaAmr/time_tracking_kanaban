import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [GetTask] use case.
class GetTaskParams extends Equatable {
  /// The ID of the task to retrieve.
  final String id;

  /// Creates [GetTaskParams] with the given [id].
  const GetTaskParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// Use case for retrieving a single task by its ID.
///
/// This use case fetches a specific task from the repository using
/// the task ID provided in the parameters.
@lazySingleton
class GetTask implements UseCase<Task, GetTaskParams> {
  /// The repository to fetch the task from.
  final TasksRepository repository;

  /// Creates a [GetTask] use case with the given [repository].
  GetTask(this.repository);

  @override
  Future<Result<Task>> call(GetTaskParams params) async {
    return await repository.getTask(params.id);
  }
}

