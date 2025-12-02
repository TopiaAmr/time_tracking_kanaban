import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/widgets/responsive.dart';
import 'package:time_tracking_kanaban/core/widgets/draggable_task_card.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/section.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

/// Kanban column widget displaying tasks in a vertical list.
///
/// Responsive: Adapts column width and layout for different screen sizes
class KanbanColumn extends StatelessWidget {
  /// Section this column represents (null for "No Section" column).
  final Section? section;

  /// List of tasks in this column.
  final List<Task> tasks;

  /// Callback when a task is tapped.
  final ValueChanged<Task>? onTaskTap;

  /// Callback when "Add Task" is tapped.
  final VoidCallback? onAddTask;

  /// Callback when a task is dropped on this column.
  final ValueChanged<Task>? onTaskDropped;

  const KanbanColumn({
    super.key,
    this.section,
    required this.tasks,
    this.onTaskTap,
    this.onAddTask,
    this.onTaskDropped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = context.isMobile;
    final columnTitle = section?.name ?? 'No Section';

    // Build the tasks list widget
    Widget tasksList = DragTarget<Task>(
      onWillAcceptWithDetails: (details) => true,
      onAcceptWithDetails: (details) {
        onTaskDropped?.call(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isDraggingOver = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isDraggingOver
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
                : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: tasks.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      isDraggingOver
                          ? 'Drop task here'
                          : context.l10n.emptyTasks,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDraggingOver
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: tasks.length,
                  shrinkWrap: isMobile, // Use shrinkWrap on mobile
                  physics: isMobile
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: DraggableTaskCard(
                        task: task,
                        onTap: () => onTaskTap?.call(task),
                        tags: task.labels.isNotEmpty
                            ? task.labels.map((l) => l.toUpperCase()).toList()
                            : null,
                        dueDate: task.due,
                        commentCount: task.noteCount,
                      ),
                    );
                  },
                ),
        );
      },
    );

    return Container(
      width: isMobile ? double.infinity : 300,
      margin: EdgeInsets.only(right: isMobile ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: isMobile ? MainAxisSize.min : MainAxisSize.max,
        children: [
          // Minimal column header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  columnTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 20),
                  onPressed: onAddTask,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Tasks list with drag target
          // On mobile, don't use Expanded (causes unbounded height error)
          // On desktop, use Expanded for proper layout
          isMobile ? tasksList : Expanded(child: tasksList),
        ],
      ),
    );
  }
}
