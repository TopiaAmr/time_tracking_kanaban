import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';

@lazySingleton
class GetSections implements UseCase<List<Section>, NoParams> {
  final TasksRepository repository;

  GetSections(this.repository);

  @override
  Future<Result<List<Section>>> call(NoParams params) async {
    return await repository.getSections();
  }
}
