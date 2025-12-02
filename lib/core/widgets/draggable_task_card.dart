import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/services/haptic_service.dart';
import 'package:time_tracking_kanaban/core/widgets/task_card.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Wrapper widget that makes a TaskCard draggable.
class DraggableTaskCard extends StatelessWidget {
  /// The task to display.
  final Task task;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// List of tag labels.
  final List<String>? tags;

  /// List of assignee avatars.
  final List<String>? assignees;

  /// Due date display.
  final DateTime? dueDate;

  /// Number of comments.
  final int commentCount;

  const DraggableTaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.tags,
    this.assignees,
    this.dueDate,
    this.commentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Task>(
      data: task,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: 280,
            child: TaskCard(
              task: task,
              tags: tags,
              assignees: assignees,
              dueDate: dueDate,
              commentCount: commentCount,
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: TaskCard(
          task: task,
          onTap: onTap,
          tags: tags,
          assignees: assignees,
          dueDate: dueDate,
          commentCount: commentCount,
        ),
      ),
      onDragStarted: () {
        HapticService.mediumImpact();
      },
      child: TaskCard(
        task: task,
        onTap: onTap,
        tags: tags,
        assignees: assignees,
        dueDate: dueDate,
        commentCount: commentCount,
      ),
    );
  }
}

