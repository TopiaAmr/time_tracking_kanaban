import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

@lazySingleton
class GetTasks implements UseCase<List<Task>, NoParams> {
  final TasksRepository repository;

  GetTasks(this.repository);

  @override
  Future<Result<List<Task>>> call(NoParams params) async {
    return await repository.getTasks();
  }
}
