import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/add_comment_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/delete_comment_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/get_task_comments_usecase.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/usecases/update_comment_usecase.dart';
import 'comments_state.dart';

/// Cubit for managing comments state.
///
/// This cubit handles loading, adding, updating, and deleting comments
/// for a task. It supports offline sync through the repository layer.
@injectable
class CommentsCubit extends Cubit<CommentsState> {
  /// Use case for getting task comments.
  final GetTaskComments _getTaskComments;

  /// Use case for adding a comment.
  final AddComment _addComment;

  /// Use case for updating a comment.
  final UpdateComment _updateComment;

  /// Use case for deleting a comment.
  final DeleteComment _deleteComment;

  /// Creates a [CommentsCubit] with the required use cases.
  CommentsCubit(
    this._getTaskComments,
    this._addComment,
    this._updateComment,
    this._deleteComment,
  ) : super(const CommentsInitial());

  /// Loads comments for a task.
  Future<void> loadComments(String taskId) async {
    emit(const CommentsLoading());

    final result = await _getTaskComments(GetTaskCommentsParams(taskId));

    if (result is Error<List<Comment>>) {
      emit(CommentsError(result.failure));
      return;
    }

    final comments = (result as Success<List<Comment>>).value;
    emit(CommentsLoaded(comments));
  }

  /// Adds a new comment to a task.
  Future<void> addComment(String taskId, String content) async {
    emit(const CommentsLoading());

    final result = await _addComment(AddCommentParams(
      taskId: taskId,
      content: content,
    ));

    if (result is Error<Comment>) {
      emit(CommentsError(result.failure));
      return;
    }

    // Reload comments after adding
    await loadComments(taskId);
  }

  /// Updates an existing comment.
  Future<void> updateComment(Comment comment, String newContent) async {
    emit(const CommentsLoading());

    final result = await _updateComment(UpdateCommentParams(
      commentId: comment.id,
      content: newContent,
    ));

    if (result is Error<Comment>) {
      emit(CommentsError(result.failure));
      return;
    }

    // Reload comments after updating
    await loadComments(comment.taskId);
  }

  /// Deletes a comment.
  Future<void> deleteComment(String commentId, String taskId) async {
    emit(const CommentsLoading());

    final result = await _deleteComment(DeleteCommentParams(commentId));

    if (result is Error<void>) {
      emit(CommentsError(result.failure));
      return;
    }

    // Reload comments after deleting
    await loadComments(taskId);
  }
}

