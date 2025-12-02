import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/services/haptic_service.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_state.dart';

/// Timer widget that displays and controls a timer for a task.
///
/// This widget can be embedded in task detail screens and automatically
/// manages timer state through TimerBloc.
class TimerWidget extends StatelessWidget {
  /// The task ID this timer is for.
  final String taskId;

  const TimerWidget({super.key, required this.taskId});

  /// Format seconds into HH:MM:SS format.
  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        // Check if this timer is for the active task
        final isActive =
            state is TimerRunning && state.timeLog.taskId == taskId;
        final isPaused = state is TimerPaused && state.timeLog.taskId == taskId;

        if (isActive || isPaused) {
          final elapsedSeconds = isActive
              ? (state).elapsedSeconds
              : (state as TimerPaused).elapsedSeconds;

          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(elapsedSeconds),
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFeatures: [
                              const FontFeature.tabularFigures(),
                            ],
                          ),
                    ),
                    Row(
                      children: [
                        if (isPaused)
                          IconButton(
                            icon: const Icon(Icons.play_arrow),
                            onPressed: () {
                              HapticService.mediumImpact();
                              context.read<TimerBloc>().add(
                                ResumeTimer(taskId),
                              );
                            },
                            tooltip: context.l10n.timerResume,
                          ),
                        if (isActive)
                          IconButton(
                            icon: const Icon(Icons.pause),
                            onPressed: () {
                              HapticService.mediumImpact();
                              context.read<TimerBloc>().add(
                                const PauseTimer(),
                              );
                            },
                            tooltip: context.l10n.timerPause,
                          ),
                        IconButton(
                          icon: const Icon(Icons.stop),
                          onPressed: () {
                            HapticService.heavyImpact();
                            context.read<TimerBloc>().add(const StopTimer());
                          },
                          tooltip: context.l10n.timerStop,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        // No active timer for this task
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
             border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.timerStart,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              ElevatedButton.icon(
                onPressed: () {
                  HapticService.heavyImpact();
                  context.read<TimerBloc>().add(StartTimer(taskId));
                },
                icon: const Icon(Icons.play_arrow),
                label: Text(context.l10n.timerStart),
              ),
            ],
          ),
        );
      },
    );
  }
}
