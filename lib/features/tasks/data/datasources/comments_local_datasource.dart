import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/comment_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';

/// Local datasource for storing and retrieving comments.
///
/// This datasource handles all local database operations for comments,
/// including storing comments locally for offline access and syncing with API.
@injectable
class CommentsLocalDataSource {
  final AppDatabase _db;

  CommentsLocalDataSource(this._db);

  /// Retrieves a single comment by ID.
  Future<Result<Comment>> getCommentById(String commentId) async {
    try {
      final query = _db.select(_db.commentsTable)
        ..where((tbl) => tbl.id.equals(commentId))
        ..limit(1);
      final row = await query.getSingleOrNull();
      if (row == null) {
        return Error(CacheFailure(['Comment not found']));
      }
      return Success(_commentRowToEntity(row));
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Retrieves all comments for a specific task.
  Future<Result<List<Comment>>> getCommentsForTask(String taskId) async {
    try {
      final query = _db.select(_db.commentsTable)
        ..where((tbl) => tbl.taskId.equals(taskId))
        ..orderBy([(tbl) => OrderingTerm.desc(tbl.createdAt)]);
      final rows = await query.get();
      final comments = rows.map((row) => _commentRowToEntity(row)).toList();
      return Success(comments);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Caches a list of comments from the API.
  Future<Result<void>> cacheComments(
    List<CommentModel> comments,
    String taskId,
  ) async {
    try {
      await _db.batch((batch) {
        for (final comment in comments) {
          batch.insert(
            _db.commentsTable,
            CommentsTableCompanion(
              id: Value(comment.id),
              taskId: Value(taskId),
              content: Value(comment.content),
              createdAt: Value(comment.postedAt),
              updatedAt: Value(comment.postedAt),
              authorId: Value(comment.postedUid),
              authorName: const Value(null),
              isSynced: const Value(true),
            ),
            mode: InsertMode.replace,
          );
        }
      });
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Adds a comment to the local database.
  Future<Result<Comment>> addComment(Comment comment) async {
    try {
      await _db.into(_db.commentsTable).insert(
            CommentsTableCompanion(
              id: Value(comment.id),
              taskId: Value(comment.taskId),
              content: Value(comment.content),
              createdAt: Value(comment.createdAt),
              updatedAt: Value(comment.updatedAt),
              authorId: Value(comment.authorId),
              authorName: Value(comment.authorName),
              isSynced: Value(comment.isSynced),
            ),
            mode: InsertMode.replace,
          );
      return Success(comment);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Updates a comment in the local database.
  Future<Result<Comment>> updateComment(Comment comment) async {
    try {
      await (_db.update(_db.commentsTable)
            ..where((tbl) => tbl.id.equals(comment.id)))
          .write(CommentsTableCompanion(
        content: Value(comment.content),
        updatedAt: Value(comment.updatedAt),
        isSynced: Value(comment.isSynced),
      ));
      return Success(comment);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Deletes a comment from the local database.
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      await (_db.delete(_db.commentsTable)
            ..where((tbl) => tbl.id.equals(commentId)))
          .go();
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Gets all unsynced comments (comments that were created/updated/deleted offline).
  Future<Result<List<Comment>>> getUnsyncedComments() async {
    try {
      final query = _db.select(_db.commentsTable)
        ..where((tbl) => tbl.isSynced.equals(false));
      final rows = await query.get();
      final comments = rows.map((row) => _commentRowToEntity(row)).toList();
      return Success(comments);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Marks a comment as synced.
  Future<Result<void>> markCommentAsSynced(String commentId) async {
    try {
      await (_db.update(_db.commentsTable)
            ..where((tbl) => tbl.id.equals(commentId)))
          .write(const CommentsTableCompanion(isSynced: Value(true)));
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure([e.toString()]));
    }
  }

  /// Helper method to convert database row to entity
  Comment _commentRowToEntity(CommentsTableData row) {
    return Comment(
      id: row.id,
      taskId: row.taskId,
      content: row.content,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      authorId: row.authorId,
      authorName: row.authorName,
      isSynced: row.isSynced,
    );
  }
}

