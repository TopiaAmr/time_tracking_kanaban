import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

class TaskDatesSection extends StatelessWidget {
  final Task task;

  const TaskDatesSection({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.event_outlined,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.taskDates,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Due date
            if (task.due != null) ...[
              _buildDateRow(
                context,
                theme,
                icon: Icons.calendar_today,
                label: context.l10n.taskDueDate,
                date: task.due!,
              ),
              const SizedBox(height: 12),
            ],
            // Created date
            _buildDateRow(
              context,
              theme,
              icon: Icons.add_circle_outline,
              label: context.l10n.taskCreatedAt,
              date: task.addedAt,
            ),
            const SizedBox(height: 12),
            // Updated date
            _buildDateRow(
              context,
              theme,
              icon: Icons.update,
              label: context.l10n.taskUpdatedAt,
              date: task.updatedAt,
            ),
            // Completed date
            if (task.completedAt != null) ...[
              const SizedBox(height: 12),
              _buildDateRow(
                context,
                theme,
                icon: Icons.check_circle_outline,
                label: context.l10n.taskCompletedAt,
                date: task.completedAt!,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required DateTime date,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('MMM d, yyyy HH:mm').format(date),
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
