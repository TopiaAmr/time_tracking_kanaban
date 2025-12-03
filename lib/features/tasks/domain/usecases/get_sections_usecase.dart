import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

/// Parameters for [GetSections].
class GetSectionsParams extends Equatable {
  /// Whether to force refresh from API and update local cache.
  final bool forceRefresh;

  const GetSectionsParams({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Use case for retrieving all sections.
///
/// This use case fetches all sections accessible to the current user
/// from the repository.
@lazySingleton
class GetSections implements UseCase<List<Section>, GetSectionsParams> {
  /// The repository to fetch sections from.
  final TasksRepository repository;

  /// Creates a [GetSections] use case with the given [repository].
  GetSections(this.repository);

  @override
  Future<Result<List<Section>>> call(GetSectionsParams params) async {
    return await repository.getSections(forceRefresh: params.forceRefresh);
  }
}
