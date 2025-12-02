import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

class GetTaskParams extends Equatable {
  final String id;

  const GetTaskParams(this.id);

  @override
  List<Object?> get props => [id];
}

@lazySingleton
class GetTask implements UseCase<Task, GetTaskParams> {
  final TasksRepository repository;

  GetTask(this.repository);

  @override
  Future<Result<Task>> call(GetTaskParams params) async {
    return await repository.getTask(params.id);
  }
}

