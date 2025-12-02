import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

class TaskAssigneesSection extends StatelessWidget {
  final Task task;

  const TaskAssigneesSection({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (task.responsibleUid == null && task.assignedByUid == null) {
      return const SizedBox.shrink();
    }

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
                  Icons.people_outline,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  context.l10n.taskAssignees,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                if (task.responsibleUid != null)
                  _buildAssigneeChip(
                    theme,
                    task.responsibleUid!,
                    isResponsible: true,
                  ),
                if (task.assignedByUid != null)
                  _buildAssigneeChip(
                    theme,
                    task.assignedByUid!,
                    isResponsible: false,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssigneeChip(
    ThemeData theme,
    String uid, {
    required bool isResponsible,
  }) {
    return Chip(
      avatar: CircleAvatar(
        radius: 12,
        backgroundColor: theme.colorScheme.primaryContainer,
        child: Text(
          uid.isNotEmpty ? uid[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      label: Text(uid, style: theme.textTheme.bodySmall),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
