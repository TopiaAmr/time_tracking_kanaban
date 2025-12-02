import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [CloseTask] use case.
class CloseTaskParams extends Equatable {
  /// The task to close.
  final Task task;

  /// Creates [CloseTaskParams] with the given [task].
  const CloseTaskParams(this.task);

  @override
  List<Object?> get props => [task];
}

/// Use case for closing (completing) a task.
///
/// This use case marks a task as completed by setting its `checked` flag
/// to `true` and updating the `completedAt` timestamp. The updated task
/// is returned.
@lazySingleton
class CloseTask implements UseCase<Task, CloseTaskParams> {
  /// The repository to update the task in.
  final TasksRepository repository;

  /// Creates a [CloseTask] use case with the given [repository].
  CloseTask(this.repository);

  @override
  Future<Result<Task>> call(CloseTaskParams params) async {
    final updatedTask = Task(
      userId: params.task.userId,
      id: params.task.id,
      projectId: params.task.projectId,
      sectionId: params.task.sectionId,
      parentId: params.task.parentId,
      addedByUid: params.task.addedByUid,
      assignedByUid: params.task.assignedByUid,
      responsibleUid: params.task.responsibleUid,
      labels: params.task.labels,
      deadline: params.task.deadline,
      duration: params.task.duration,
      checked: true,
      isDeleted: params.task.isDeleted,
      addedAt: params.task.addedAt,
      completedAt: DateTime.now(),
      completedByUid: params.task.completedByUid,
      updatedAt: DateTime.now(),
      due: params.task.due,
      priority: params.task.priority,
      childOrder: params.task.childOrder,
      content: params.task.content,
      description: params.task.description,
      noteCount: params.task.noteCount,
      dayOrder: params.task.dayOrder,
      isCollapsed: params.task.isCollapsed,
    );
    return await repository.updateTask(updatedTask);
  }
}
