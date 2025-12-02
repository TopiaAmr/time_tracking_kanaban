import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

class GetSectionParams extends Equatable {
  final String id;

  const GetSectionParams(this.id);

  @override
  List<Object?> get props => [id];
}

@lazySingleton
class GetSection implements UseCase<Section, GetSectionParams> {
  final TasksRepository repository;

  GetSection(this.repository);

  @override
  Future<Result<Section>> call(GetSectionParams params) async {
    return await repository.getSection(params.id);
  }
}
