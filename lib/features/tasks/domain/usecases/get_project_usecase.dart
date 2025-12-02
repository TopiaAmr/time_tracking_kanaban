import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

class GetProjectParams extends Equatable {
  final String id;

  const GetProjectParams(this.id);

  @override
  List<Object?> get props => [id];
}

@lazySingleton
class GetProject implements UseCase<Project, GetProjectParams> {
  final TasksRepository repository;

  GetProject(this.repository);

  @override
  Future<Result<Project>> call(GetProjectParams params) async {
    return await repository.getProject(params.id);
  }
}
