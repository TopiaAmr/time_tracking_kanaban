import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/services/haptic_service.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_state.dart';

/// Kanban task card widget.
///
/// Responsive: Adapts size and layout for different screen sizes
class TaskCard extends StatelessWidget {
  /// The task to display.
  final Task task;

  /// Callback when card is tapped.
  final VoidCallback? onTap;

  /// Callback when card is long pressed.
  final VoidCallback? onLongPress;

  /// List of tag labels (from task.labels or custom).
  final List<String>? tags;

  /// List of assignee avatars (user IDs or names).
  final List<String>? assignees;

  /// Due date display.
  final DateTime? dueDate;

  /// Number of comments.
  final int commentCount;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onLongPress,
    this.tags,
    this.assignees,
    this.dueDate,
    this.commentCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, timerState) {
        final isActive =
            timerState is TimerRunning && timerState.timeLog.taskId == task.id;
        final isPaused =
            timerState is TimerPaused && timerState.timeLog.taskId == task.id;
        final hasActiveTimer = isActive || isPaused;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: hasActiveTimer
                ? BorderSide(color: theme.colorScheme.primary, width: 2)
                : BorderSide.none,
          ),
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (tags != null && tags!.isNotEmpty) ...[
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags!.take(3).map((tag) {
                        return _TagChip(label: tag);
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Title
                  Text(
                    task.content.isEmpty
                        ? context.l10n.taskTitle
                        : task.content,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Description
                  if (task.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      task.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Footer row
                  Row(
                    children: [
                      // Assignees
                      if (assignees != null && assignees!.isNotEmpty) ...[
                        _AvatarGroup(
                          avatars: assignees!.take(3).toList(),
                          overflow: assignees!.length > 3
                              ? assignees!.length - 3
                              : null,
                        ),
                        const SizedBox(width: 8),
                      ],

                      // Due date
                      if (dueDate != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(context, dueDate!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Comment count
                      if (commentCount > 0) ...[
                        Icon(
                          Icons.comment_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          commentCount.toString(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Timer quick action
                      const Spacer(),
                      _TimerQuickAction(
                        taskId: task.id,
                        isActive: isActive,
                        isPaused: isPaused,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return context.l10n.today;
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return context.l10n.yesterday;
    } else {
      return DateFormat('EEE, MMM d').format(date);
    }
  }
}

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _AvatarGroup extends StatelessWidget {
  final List<String> avatars;
  final int? overflow;

  const _AvatarGroup({required this.avatars, this.overflow});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        ...avatars.asMap().entries.map((entry) {
          final index = entry.key;
          final avatar = entry.value;
          return Transform.translate(
            offset: Offset(index > 0 ? -8.0 * index : 0, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  avatar.isNotEmpty ? avatar[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
        if (overflow != null && overflow! > 0)
          Transform.translate(
            offset: Offset(-8.0 * avatars.length, 0),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: theme.colorScheme.surface, width: 2),
              ),
              child: CircleAvatar(
                radius: 12,
                backgroundColor: theme.colorScheme.surface.withValues(
                  alpha: 0.5,
                ),
                child: Text(
                  '+$overflow',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Quick action button for timer control in task cards.
class _TimerQuickAction extends StatelessWidget {
  final String taskId;
  final bool isActive;
  final bool isPaused;

  const _TimerQuickAction({
    required this.taskId,
    required this.isActive,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isActive) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pulsing indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary,
            ),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.3, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(opacity: value, child: child);
              },
              onEnd: () {},
            ),
          ),
          const SizedBox(width: 6),
          IconButton(
            icon: const Icon(Icons.pause, size: 18),
            onPressed: () {
              HapticService.mediumImpact();
              context.read<TimerBloc>().add(const PauseTimer());
            },
            tooltip: context.l10n.timerPause,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            color: theme.colorScheme.primary,
          ),
        ],
      );
    } else if (isPaused) {
      return IconButton(
        icon: const Icon(Icons.play_arrow, size: 18),
        onPressed: () {
          HapticService.mediumImpact();
          context.read<TimerBloc>().add(ResumeTimer(taskId));
        },
        tooltip: context.l10n.timerResume,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: theme.colorScheme.primary,
      );
    } else {
      return IconButton(
        icon: const Icon(Icons.play_arrow, size: 18),
        onPressed: () {
          HapticService.heavyImpact();
          context.read<TimerBloc>().add(StartTimer(taskId));
        },
        tooltip: context.l10n.timerStart,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      );
    }
  }
}
