import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

class UpdateTaskParams extends Equatable {
  final Task task;

  const UpdateTaskParams(this.task);

  @override
  List<Object?> get props => [task];
}

@lazySingleton
class UpdateTask implements UseCase<Task, UpdateTaskParams> {
  final TasksRepository repository;

  UpdateTask(this.repository);

  @override
  Future<Result<Task>> call(UpdateTaskParams params) async {
    return await repository.updateTask(params.task);
  }
}

