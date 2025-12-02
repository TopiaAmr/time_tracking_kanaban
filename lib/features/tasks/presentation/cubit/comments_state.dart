import 'package:equatable/equatable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';

/// Base class for comments states.
abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when the comments view is first created.
class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

/// State when comments are being loaded.
class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

/// State when comments have been successfully loaded.
class CommentsLoaded extends CommentsState {
  /// List of comments for the task.
  final List<Comment> comments;

  const CommentsLoaded(this.comments);

  @override
  List<Object?> get props => [comments];
}

/// State when an error occurs.
class CommentsError extends CommentsState {
  /// The failure that occurred.
  final Failure failure;

  const CommentsError(this.failure);

  @override
  List<Object?> get props => [failure];
}

