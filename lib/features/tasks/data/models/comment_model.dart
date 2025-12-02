import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/comment.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

/// Data model representing a comment from the Todoist API.
///
/// This model is used for JSON serialization/deserialization when communicating
/// with the Todoist API. It can be converted to a domain [Comment] entity using
/// the [toEntity] method.
@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._();

  const factory CommentModel({
    required String id,
    @JsonKey(name: 'posted_uid') required String postedUid,
    required String content,
    @JsonKey(name: 'file_attachment') Map<String, dynamic>? fileAttachment,
    @JsonKey(name: 'uids_to_notify') List<String>? uidsToNotify,
    @JsonKey(name: 'is_deleted') @Default(false) bool isDeleted,
    @JsonKey(name: 'posted_at') required DateTime postedAt,
    Map<String, List<String>>? reactions,
  }) = _CommentModel;

  /// Creates a [CommentModel] from a JSON map.
  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  /// Converts this model to a domain [Comment] entity.
  ///
  /// Note: This requires taskId which is not in the API response,
  /// so it should be provided separately when converting.
  Comment toEntity({required String taskId, bool isSynced = true}) => Comment(
    id: id,
    taskId: taskId,
    content: content,
    createdAt: postedAt,
    updatedAt: postedAt,
    authorId: postedUid,
    authorName: null,
    isSynced: isSynced,
  );
}

/// Request body for creating a comment
@freezed
abstract class CreateCommentBody with _$CreateCommentBody {
  const factory CreateCommentBody({
    required String content,
    @JsonKey(name: 'project_id') String? projectId,
    @JsonKey(name: 'task_id') String? taskId,
  }) = _CreateCommentBody;

  factory CreateCommentBody.fromJson(Map<String, dynamic> json) =>
      _$CreateCommentBodyFromJson(json);
}

/// Request body for updating a comment
@freezed
abstract class UpdateCommentBody with _$UpdateCommentBody {
  const factory UpdateCommentBody({required String content}) =
      _UpdateCommentBody;

  factory UpdateCommentBody.fromJson(Map<String, dynamic> json) =>
      _$UpdateCommentBodyFromJson(json);
}

/// Response wrapper for paginated comments
@freezed
abstract class CommentsResponse with _$CommentsResponse {
  const factory CommentsResponse({
    required List<CommentModel> results,
    @JsonKey(name: 'next_cursor') String? nextCursor,
  }) = _CommentsResponse;

  factory CommentsResponse.fromJson(Map<String, dynamic> json) =>
      _$CommentsResponseFromJson(json);
}
