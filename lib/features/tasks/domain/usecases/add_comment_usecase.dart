import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/comments_repository.dart';

/// Parameters for the [AddComment] use case.
class AddCommentParams extends Equatable {
  /// The ID of the task to add the comment to.
  final String taskId;
  
  /// The content of the comment.
  final String content;

  /// Creates [AddCommentParams] with the given [taskId] and [content].
  const AddCommentParams({
    required this.taskId,
    required this.content,
  });

  @override
  List<Object?> get props => [taskId, content];
}

/// Use case for adding a comment to a task.
///
/// This use case creates a new comment on the specified task. If the
/// device is offline, the comment is stored locally and synced when
/// connectivity is restored.
@lazySingleton
class AddComment implements UseCase<Comment, AddCommentParams> {
  /// The repository to add the comment to.
  final CommentsRepository repository;

  /// Creates an [AddComment] use case with the given [repository].
  AddComment(this.repository);

  @override
  Future<Result<Comment>> call(AddCommentParams params) async {
    return await repository.addComment(params.taskId, params.content);
  }
}

