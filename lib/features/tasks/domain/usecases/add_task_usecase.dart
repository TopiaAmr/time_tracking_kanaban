import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

class AddTaskParams extends Equatable {
  final Task task;

  const AddTaskParams(this.task);

  @override
  List<Object?> get props => [task];
}

@lazySingleton
class AddTask implements UseCase<Task, AddTaskParams> {
  final TasksRepository repository;

  AddTask(this.repository);

  @override
  Future<Result<Task>> call(AddTaskParams params) async {
    return await repository.createTask(params.task);
  }
}
