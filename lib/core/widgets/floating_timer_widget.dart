import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n.dart';
import 'package:time_tracking_kanaban/core/navigation/route_names.dart';
import 'package:time_tracking_kanaban/core/services/haptic_service.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_state.dart';

/// Floating bottom widget that displays the currently running timer.
/// 
/// This widget appears at the bottom of the screen with a smooth animation
/// when a timer is active, showing the task name, elapsed time, and controls.
class FloatingTimerWidget extends StatefulWidget {
  const FloatingTimerWidget({super.key});

  @override
  State<FloatingTimerWidget> createState() => _FloatingTimerWidgetState();
}

class _FloatingTimerWidgetState extends State<FloatingTimerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocBuilder<TimerBloc, TimerState>(
      builder: (context, state) {
        final isActive = state is TimerRunning;
        final isPaused = state is TimerPaused;
        final hasActiveTimer = isActive || isPaused;

        if (hasActiveTimer) {
          _animationController.forward();
        } else {
          _animationController.reverse();
        }

        if (!hasActiveTimer) {
          return const SizedBox.shrink();
        }

        final timeLog = isActive
            ? state.timeLog
            : (state as TimerPaused).timeLog;
        final elapsedSeconds = isActive
            ? state.elapsedSeconds
            : (state as TimerPaused).elapsedSeconds;

        return SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              margin: EdgeInsets.only(
                left: isMobile ? 8 : 16,
                right: isMobile ? 8 : 16,
                bottom: isMobile ? 8 : 16,
              ),
              child: Material(
                elevation: 8,
                borderRadius: BorderRadius.circular(16),
                color: theme.colorScheme.primaryContainer,
                child: InkWell(
                  onTap: () {
                    HapticService.lightImpact();
                    context.go('${RouteNames.tasks}/${timeLog.taskId}');
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isMobile ? screenWidth - 16 : 600,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 16 : 20,
                      vertical: isMobile ? 12 : 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated timer icon
                        Container(
                          width: isMobile ? 40 : 48,
                          height: isMobile ? 40 : 48,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              if (isActive)
                                _PulsingCircle(
                                  color: theme.colorScheme.primary,
                                ),
                              Icon(
                                isActive ? Icons.timer : Icons.pause_circle_filled,
                                color: theme.colorScheme.onPrimary,
                                size: isMobile ? 20 : 24,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: isMobile ? 12 : 16),

                        // Task info and timer
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isActive
                                    ? 'Timer Running'
                                    : 'Timer Paused',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDuration(elapsedSeconds),
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontFeatures: [
                                    const FontFeature.tabularFigures(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Control buttons
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isActive)
                              IconButton(
                                icon: Icon(
                                  Icons.pause,
                                  size: isMobile ? 20 : 24,
                                ),
                                onPressed: () {
                                  HapticService.mediumImpact();
                                  context.read<TimerBloc>().add(const PauseTimer());
                                },
                                tooltip: context.l10n.timerPause,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            if (isPaused)
                              IconButton(
                                icon: Icon(
                                  Icons.play_arrow,
                                  size: isMobile ? 20 : 24,
                                ),
                                onPressed: () {
                                  HapticService.mediumImpact();
                                  context
                                      .read<TimerBloc>()
                                      .add(ResumeTimer(timeLog.taskId));
                                },
                                tooltip: context.l10n.timerResume,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            IconButton(
                              icon: Icon(
                                Icons.stop,
                                size: isMobile ? 20 : 24,
                              ),
                              onPressed: () {
                                HapticService.heavyImpact();
                                context.read<TimerBloc>().add(const StopTimer());
                              },
                              tooltip: context.l10n.timerStop,
                              color: theme.colorScheme.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Animated pulsing circle widget for the timer indicator.
class _PulsingCircle extends StatefulWidget {
  final Color color;

  const _PulsingCircle({required this.color});

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animation.value * 0.2),
          child: Opacity(
            opacity: 1.0 - _animation.value,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.color,
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
