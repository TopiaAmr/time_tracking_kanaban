import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';

/// Abstraction over comment operations.
///
/// Infrastructure implementations are responsible for:
/// - Fetching comments from the Todoist API.
/// - Storing comments locally in Drift for offline access.
/// - Syncing unsynced comments when connectivity is restored.
abstract class CommentsRepository {
  /// Returns all comments for the given [taskId].
  ///
  /// Should return comments from local storage first, then sync with
  /// the API if connectivity is available.
  Future<Result<List<Comment>>> getCommentsForTask(String taskId);

  /// Adds a new comment to the specified task.
  ///
  /// If offline, the comment should be stored locally with `isSynced = false`
  /// and synced later when connectivity is restored.
  Future<Result<Comment>> addComment(String taskId, String content);

  /// Deletes a comment by its [commentId].
  Future<Result<void>> deleteComment(String commentId);

  /// Updates an existing comment.
  ///
  /// If offline, the update should be stored locally and synced later.
  Future<Result<Comment>> updateComment(String commentId, String content);

  /// Syncs pending changes (comments created/updated/deleted offline) with the API.
  ///
  /// This method should be called when connectivity is restored to sync
  /// any local changes that were made while offline.
  Future<Result<void>> syncPendingChanges();
}

