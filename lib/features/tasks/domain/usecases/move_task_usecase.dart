import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

class MoveTaskParams extends Equatable {
  final Task task;
  final String projectId;
  final String sectionId;

  const MoveTaskParams({
    required this.task,
    required this.projectId,
    required this.sectionId,
  });

  @override
  List<Object?> get props => [task, projectId, sectionId];
}

@lazySingleton
class MoveTask implements UseCase<Task, MoveTaskParams> {
  final TasksRepository repository;

  MoveTask(this.repository);

  @override
  Future<Result<Task>> call(MoveTaskParams params) async {
    return await repository.moveTask(params.task, params.projectId, params.sectionId);
  }
}

