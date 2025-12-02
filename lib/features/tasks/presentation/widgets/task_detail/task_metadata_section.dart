import 'package:flutter/material.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/project.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';

class TaskMetadataSection extends StatelessWidget {
  final Task task;
  final Project? project;

  const TaskMetadataSection({
    super.key,
    required this.task,
    this.project,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // Priority card
        _buildInfoCard(
          context,
          theme,
          icon: Icons.flag_outlined,
          title: context.l10n.taskPriority,
          child: _buildPriorityIndicator(context, theme),
        ),

        // Project card
        if (project != null)
          _buildInfoCard(
            context,
            theme,
            icon: Icons.folder_outlined,
            title: context.l10n.taskProject,
            child: Text(
              project!.name,
              style: theme.textTheme.bodyMedium,
            ),
          ),

        // Duration card
        if (task.duration != null)
          _buildInfoCard(
            context,
            theme,
            icon: Icons.access_time,
            title: context.l10n.taskDuration,
            child: Text(
              '${task.duration} ${context.l10n.taskMinutes}',
              style: theme.textTheme.bodyMedium,
            ),
          ),

        // Labels card
        if (task.labels.isNotEmpty)
          _buildInfoCard(
            context,
            theme,
            icon: Icons.label_outline,
            title: context.l10n.taskLabels,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: task.labels.map((labelId) {
                return Chip(
                  label: Text(labelId),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width < 600 ? double.infinity : 200,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIndicator(BuildContext context, ThemeData theme) {
    final priority = task.priority;
    Color priorityColor;
    String priorityText;

    switch (priority) {
      case 4:
        priorityColor = theme.colorScheme.error;
        priorityText = context.l10n.taskPriorityP1;
        break;
      case 3:
        priorityColor = theme.colorScheme.error.withValues(alpha: 0.7);
        priorityText = context.l10n.taskPriorityP2;
        break;
      case 2:
        priorityColor = theme.colorScheme.primary;
        priorityText = context.l10n.taskPriorityP3;
        break;
      default:
        priorityColor = theme.colorScheme.onSurface.withValues(alpha: 0.5);
        priorityText = context.l10n.taskPriorityP4;
    }

    return Row(
      children: [
        Icon(Icons.flag, color: priorityColor, size: 20),
        const SizedBox(width: 8),
        Text(
          priorityText,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: priorityColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
