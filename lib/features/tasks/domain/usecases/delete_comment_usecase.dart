import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/usecases/usecase.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/comments_repository.dart';

/// Parameters for the [DeleteComment] use case.
class DeleteCommentParams extends Equatable {
  /// The ID of the comment to delete.
  final String commentId;

  /// Creates [DeleteCommentParams] with the given [commentId].
  const DeleteCommentParams(this.commentId);

  @override
  List<Object?> get props => [commentId];
}

/// Use case for deleting a comment.
///
/// This use case permanently deletes a comment by its ID. This operation
/// cannot be undone.
@lazySingleton
class DeleteComment implements UseCase<void, DeleteCommentParams> {
  /// The repository to delete the comment from.
  final CommentsRepository repository;

  /// Creates a [DeleteComment] use case with the given [repository].
  DeleteComment(this.repository);

  @override
  Future<Result<void>> call(DeleteCommentParams params) async {
    return await repository.deleteComment(params.commentId);
  }
}

