import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

/// Use case for retrieving all projects.
///
/// This use case fetches all projects accessible to the current user
/// from the repository.
@lazySingleton
class GetProjects implements UseCase<List<Project>, NoParams> {
  /// The repository to fetch projects from.
  final TasksRepository repository;

  /// Creates a [GetProjects] use case with the given [repository].
  GetProjects(this.repository);

  @override
  Future<Result<List<Project>>> call(NoParams params) async {
    return await repository.getProjects();
  }
}
