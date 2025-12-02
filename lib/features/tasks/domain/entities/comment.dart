import 'package:equatable/equatable.dart';

/// Domain entity representing a comment on a task.
///
/// Comments are associated with tasks and can be created by users.
/// They support offline-first functionality where comments are stored
/// locally and synced when connectivity is available.
class Comment extends Equatable {
  final String id;
  final String taskId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String authorId;
  final String? authorName;
  final bool isSynced;

  const Comment({
    required this.id,
    required this.taskId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.authorId,
    this.authorName,
    required this.isSynced,
  });

  @override
  List<Object?> get props => [
        id,
        taskId,
        content,
        createdAt,
        updatedAt,
        authorId,
        authorName,
        isSynced,
      ];
}

