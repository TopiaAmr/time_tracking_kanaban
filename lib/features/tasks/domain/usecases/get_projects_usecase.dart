import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

@lazySingleton
class GetProjects implements UseCase<List<Project>, NoParams> {
  final TasksRepository repository;

  GetProjects(this.repository);

  @override
  Future<Result<List<Project>>> call(NoParams params) async {
    return await repository.getProjects();
  }
}
