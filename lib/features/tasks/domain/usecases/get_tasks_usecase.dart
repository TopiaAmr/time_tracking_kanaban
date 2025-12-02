import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

/// Use case for retrieving all tasks.
///
/// This use case fetches all tasks accessible to the current user
/// from the repository.
@lazySingleton
class GetTasksUseCase implements UseCase<List<Task>, NoParams> {
  /// The repository to fetch tasks from.
  final TasksRepository repository;

  /// Creates a [GetTasksUseCase] use case with the given [repository].
  GetTasksUseCase(this.repository);

  @override
  Future<Result<List<Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}
