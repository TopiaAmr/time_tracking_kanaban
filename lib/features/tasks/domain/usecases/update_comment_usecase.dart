import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/comments_repository.dart';

/// Parameters for the [UpdateComment] use case.
class UpdateCommentParams extends Equatable {
  /// The ID of the comment to update.
  final String commentId;
  
  /// The new content for the comment.
  final String content;

  /// Creates [UpdateCommentParams] with the given [commentId] and [content].
  const UpdateCommentParams({
    required this.commentId,
    required this.content,
  });

  @override
  List<Object?> get props => [commentId, content];
}

/// Use case for updating an existing comment.
///
/// This use case updates the content of a comment. If the device is offline,
/// the update is stored locally and synced when connectivity is restored.
@lazySingleton
class UpdateComment implements UseCase<Comment, UpdateCommentParams> {
  /// The repository to update the comment in.
  final CommentsRepository repository;

  /// Creates an [UpdateComment] use case with the given [repository].
  UpdateComment(this.repository);

  @override
  Future<Result<Comment>> call(UpdateCommentParams params) async {
    return await repository.updateComment(params.commentId, params.content);
  }
}

