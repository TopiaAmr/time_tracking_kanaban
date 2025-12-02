import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/errors/failure.dart';
import 'package:time_tracking_kanaban/core/network/connectivity_service.dart';
import 'package:time_tracking_kanaban/core/utils/result.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/comments_local_datasource.dart';
import 'package:time_tracking_kanaban/features/tasks/data/datasources/todoist_api.dart';
import 'package:time_tracking_kanaban/features/tasks/data/models/comment_model.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/comment.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/comments_repository.dart';

/// Implementation of [CommentsRepository] with offline support.
///
/// This implementation follows an offline-first strategy:
/// - Checks connectivity before making API calls
/// - Caches all API responses to local database
/// - Returns cached data when offline
/// - Stores write operations locally when offline for later sync
@Injectable(as: CommentsRepository)
class CommentsRepositoryImpl implements CommentsRepository {
  final TodoistApi api;
  final CommentsLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  CommentsRepositoryImpl(
    this.api,
    this.localDataSource,
    this.connectivityService,
  );

  @override
  Future<Result<List<Comment>>> getCommentsForTask(String taskId) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        // Fetch from API
        final response = await api.getComments(taskId: taskId);
        // Cache the results
        await localDataSource.cacheComments(response.results, taskId);
        // Return cached data
        return await localDataSource.getCommentsForTask(taskId);
      } on DioException catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCommentsForTask(taskId);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        // If API fails, try cached data
        final cachedResult = await localDataSource.getCommentsForTask(taskId);
        if (cachedResult is Success) {
          return cachedResult;
        }
        return Error(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: return cached data
      return await localDataSource.getCommentsForTask(taskId);
    }
  }

  @override
  Future<Result<Comment>> addComment(String taskId, String content) async {
    final isConnected = await connectivityService.isConnected();
    final now = DateTime.now();
    final commentId = 'temp_${now.millisecondsSinceEpoch}';

    final comment = Comment(
      id: commentId,
      taskId: taskId,
      content: content,
      createdAt: now,
      updatedAt: now,
      authorId: 'current_user', // This should come from auth service
      authorName: null,
      isSynced: false,
    );

    if (isConnected) {
      try {
        final body = CreateCommentBody(
          content: content,
          taskId: taskId,
        );
        final model = await api.addComment(body);
        final createdComment = model.toEntity(taskId: taskId, isSynced: true);
        // Cache the created comment
        await localDataSource.addComment(createdComment);
        return Success(createdComment);
      } on DioException catch (e) {
        // If API fails, store locally for later sync
        await localDataSource.addComment(comment);
        return Error(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        // If API fails, store locally for later sync
        await localDataSource.addComment(comment);
        return Error(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: store locally with isSynced: false
      final storeResult = await localDataSource.addComment(comment);
      if (storeResult is Error) {
        return storeResult;
      }
      return Success(comment);
    }
  }

  @override
  Future<Result<Comment>> updateComment(String commentId, String content) async {
    final isConnected = await connectivityService.isConnected();

    // Get existing comment
    final existingResult = await localDataSource.getCommentById(commentId);
    if (existingResult is Error) {
      return existingResult;
    }
    final existingComment = (existingResult as Success<Comment>).value;

    final updatedComment = Comment(
      id: existingComment.id,
      taskId: existingComment.taskId,
      content: content,
      createdAt: existingComment.createdAt,
      updatedAt: DateTime.now(),
      authorId: existingComment.authorId,
      authorName: existingComment.authorName,
      isSynced: false,
    );

    if (isConnected) {
      try {
        final body = UpdateCommentBody(content: content);
        final model = await api.updateComment(commentId, body);
        final syncedComment = model.toEntity(
          taskId: existingComment.taskId,
          isSynced: true,
        );
        // Update cache
        await localDataSource.updateComment(syncedComment);
        return Success(syncedComment);
      } on DioException catch (e) {
        // If API fails, update locally for later sync
        await localDataSource.updateComment(updatedComment);
        return Error(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        // If API fails, update locally for later sync
        await localDataSource.updateComment(updatedComment);
        return Error(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: update locally with isSynced: false
      final updateResult = await localDataSource.updateComment(updatedComment);
      if (updateResult is Error) {
        return updateResult;
      }
      return Success(updatedComment);
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    final isConnected = await connectivityService.isConnected();

    if (isConnected) {
      try {
        await api.deleteComment(commentId);
        // Remove from cache
        await localDataSource.deleteComment(commentId);
        return const Success(null);
      } on DioException catch (e) {
        // If API fails, mark for deletion locally (we'll track this differently)
        // For now, just return error - in production, you'd track pending deletions
        return Error(ServerFailure([e.message, e.response?.statusCode]));
      } catch (e) {
        return Error(NetworkFailure([e.toString()]));
      }
    } else {
      // Offline: delete locally
      return await localDataSource.deleteComment(commentId);
    }
  }

  @override
  Future<Result<void>> syncPendingChanges() async {
    final isConnected = await connectivityService.isConnected();
    if (!isConnected) {
      return Error<void>(NetworkFailure(['No internet connection']));
    }

    try {
      // Get all unsynced comments
      final unsyncedResult = await localDataSource.getUnsyncedComments();
      if (unsyncedResult is Error) {
        return unsyncedResult;
      }

      final unsyncedComments = (unsyncedResult as Success<List<Comment>>).value;

      // Sync each unsynced comment
      for (final comment in unsyncedComments) {
        try {
          // Try to update first (in case comment already exists on server)
          try {
            final body = UpdateCommentBody(content: comment.content);
            await api.updateComment(comment.id, body);
            await localDataSource.markCommentAsSynced(comment.id);
          } catch (e) {
            // If update fails, try create (in case it's a new comment)
            try {
              final createBody = CreateCommentBody(
                content: comment.content,
                taskId: comment.taskId,
              );
              final model = await api.addComment(createBody);
              // Delete old comment and add new one with server ID
              await localDataSource.deleteComment(comment.id);
              final syncedComment = model.toEntity(
                taskId: comment.taskId,
                isSynced: true,
              );
              await localDataSource.addComment(syncedComment);
            } catch (e2) {
              // Continue with other comments even if one fails
              continue;
            }
          }
        } catch (e) {
          // Continue with other comments even if one fails
          continue;
        }
      }

      return const Success(null);
    } catch (e) {
      return Error<void>(NetworkFailure([e.toString()]));
    }
  }
}

