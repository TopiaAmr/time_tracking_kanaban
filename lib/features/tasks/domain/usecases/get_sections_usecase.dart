import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

/// Use case for retrieving all sections.
///
/// This use case fetches all sections accessible to the current user
/// from the repository.
@lazySingleton
class GetSections implements UseCase<List<Section>, NoParams> {
  /// The repository to fetch sections from.
  final TasksRepository repository;

  /// Creates a [GetSections] use case with the given [repository].
  GetSections(this.repository);

  @override
  Future<Result<List<Section>>> call(NoParams params) async {
    return await repository.getSections();
  }
}
