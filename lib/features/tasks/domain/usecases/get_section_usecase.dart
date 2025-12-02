import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:equatable/equatable.dart';

/// Parameters for the [GetSection] use case.
class GetSectionParams extends Equatable {
  /// The ID of the section to retrieve.
  final String id;

  /// Creates [GetSectionParams] with the given [id].
  const GetSectionParams(this.id);

  @override
  List<Object?> get props => [id];
}

/// Use case for retrieving a single section by its ID.
///
/// This use case fetches a specific section from the repository using
/// the section ID provided in the parameters.
@lazySingleton
class GetSection implements UseCase<Section, GetSectionParams> {
  /// The repository to fetch the section from.
  final TasksRepository repository;

  /// Creates a [GetSection] use case with the given [repository].
  GetSection(this.repository);

  @override
  Future<Result<Section>> call(GetSectionParams params) async {
    return await repository.getSection(params.id);
  }
}
