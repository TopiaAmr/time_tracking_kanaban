import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/comments_repository.dart';

/// Parameters for the [GetTaskComments] use case.
class GetTaskCommentsParams extends Equatable {
  /// The ID of the task to get comments for.
  final String taskId;

  /// Creates [GetTaskCommentsParams] with the given [taskId].
  const GetTaskCommentsParams(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

/// Use case for retrieving all comments for a task.
///
/// This use case fetches all comments associated with the specified task.
/// Comments are returned from local storage first, then synced with the
/// API if connectivity is available.
@lazySingleton
class GetTaskComments implements UseCase<List<Comment>, GetTaskCommentsParams> {
  /// The repository to fetch comments from.
  final CommentsRepository repository;

  /// Creates a [GetTaskComments] use case with the given [repository].
  GetTaskComments(this.repository);

  @override
  Future<Result<List<Comment>>> call(GetTaskCommentsParams params) async {
    return await repository.getCommentsForTask(params.taskId);
  }
}

