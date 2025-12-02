import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [GetProject] use case.
class GetProjectParams extends Equatable {
  /// The ID of the project to retrieve.
  final String id;

  /// Creates [GetProjectParams] with the given [id].
  const GetProjectParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// Use case for retrieving a single project by its ID.
///
/// This use case fetches a specific project from the repository using
/// the project ID provided in the parameters.
@lazySingleton
class GetProject implements UseCase<Project, GetProjectParams> {
  /// The repository to fetch the project from.
  final TasksRepository repository;

  /// Creates a [GetProject] use case with the given [repository].
  GetProject(this.repository);

  @override
  Future<Result<Project>> call(GetProjectParams params) async {
    return await repository.getProject(params.id);
  }
}
