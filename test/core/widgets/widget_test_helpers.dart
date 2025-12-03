import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_cubit.dart';
import 'package:time_tracking_kanaban/core/theme/app_theme.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/entities/task.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/time_log.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_timer_summary.dart';
import 'package:time_tracking_kanaban/features/timer/domain/entities/task_history_detail.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/l10n/app_localizations.dart';

/// Helper class for widget testing utilities.
class WidgetTestHelpers {
  /// Wraps a widget with MaterialApp, theme, and localization.
  static Widget wrapWithMaterialApp({
    required Widget child,
    ThemeData? theme,
    Locale? locale,
    Size? screenSize,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme(null),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? const Locale('en'),
      home: screenSize != null
          ? MediaQuery(
              data: MediaQueryData(size: screenSize),
              child: child,
            )
          : child,
    );
  }

  /// Wraps a widget with MaterialApp and a BLoC provider.
  static Widget
  wrapWithMaterialAppAndBloc<T extends StateStreamableSource<Object?>>({
    required Widget child,
    required T bloc,
    ThemeData? theme,
    Locale? locale,
    Size? screenSize,
  }) {
    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme(null),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? const Locale('en'),
      home: BlocProvider<T>.value(
        value: bloc,
        child: screenSize != null
            ? MediaQuery(
                data: MediaQueryData(size: screenSize),
                child: child,
              )
            : child,
      ),
    );
  }

  /// Wraps a widget with MaterialApp and multiple BLoC providers.
  static Widget wrapWithMaterialAppAndBlocs({
    required Widget child,
    required List<BlocProvider> blocProviders,
    ThemeData? theme,
    Locale? locale,
    Size? screenSize,
  }) {
    Widget wrapped = MultiBlocProvider(providers: blocProviders, child: child);

    return MaterialApp(
      theme: theme ?? AppTheme.lightTheme(null),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale ?? const Locale('en'),
      home: screenSize != null
          ? MediaQuery(
              data: MediaQueryData(size: screenSize),
              child: wrapped,
            )
          : wrapped,
    );
  }

  /// Wraps a widget with MaterialApp and common providers (TimerBloc, L10nCubit).
  /// This is useful for testing widgets that depend on these providers.
  static Widget wrapWithMaterialAppAndCommonProviders({
    required Widget child,
    TimerBloc? timerBloc,
    L10nCubit? l10nCubit,
    ThemeData? theme,
    Locale? locale,
    Size? screenSize,
  }) {
    final List<BlocProvider> providers = [];

    // Add TimerBloc provider (required for TaskCard)
    if (timerBloc != null) {
      providers.add(BlocProvider<TimerBloc>.value(value: timerBloc));
    }

    // Add L10nCubit provider (required for AppHeader and language switcher)
    if (l10nCubit != null) {
      providers.add(BlocProvider<L10nCubit>.value(value: l10nCubit));
    }

    if (providers.isEmpty) {
      return wrapWithMaterialApp(
        child: child,
        theme: theme,
        locale: locale,
        screenSize: screenSize,
      );
    }

    return wrapWithMaterialAppAndBlocs(
      child: child,
      blocProviders: providers,
      theme: theme,
      locale: locale,
      screenSize: screenSize,
    );
  }

  /// Mobile screen size (< 600px width).
  static const Size mobileSize = Size(375, 667);

  /// Desktop screen size (>= 600px width).
  static const Size desktopSize = Size(1200, 800);
}

/// Test data factories for creating test entities.
class TestDataFactory {
  static final DateTime _baseDate = DateTime(2024, 1, 1);

  /// Creates a test Task with default or custom values.
  static Task createTask({
    String? id,
    String? content,
    String? description,
    bool checked = false,
    String? projectId,
    String? sectionId,
    DateTime? due,
    int priority = 1,
    List<String>? labels,
    int noteCount = 0,
  }) {
    return Task(
      userId: 'user1',
      id: id ?? 'task1',
      projectId: projectId ?? 'project1',
      sectionId: sectionId ?? 'section1',
      addedByUid: 'user1',
      labels: labels ?? const [],
      checked: checked,
      isDeleted: false,
      addedAt: _baseDate,
      updatedAt: _baseDate,
      priority: priority,
      childOrder: 0,
      content: content ?? 'Test Task',
      description: description ?? '',
      noteCount: noteCount,
      dayOrder: 0,
      isCollapsed: false,
      due: due,
    );
  }

  /// Creates a test TimeLog with default or custom values.
  static TimeLog createTimeLog({
    String? id,
    String? taskId,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    return TimeLog(
      id: id ?? 'timelog1',
      taskId: taskId ?? 'task1',
      startTime: startTime ?? _baseDate,
      endTime: endTime,
    );
  }

  /// Creates a test TaskTimerSummary with default or custom values.
  static TaskTimerSummary createTaskTimerSummary({
    String? taskId,
    String? taskTitle,
    int? totalTrackedSeconds,
    bool? hasActiveTimer,
  }) {
    return TaskTimerSummary(
      taskId: taskId ?? 'task1',
      taskTitle: taskTitle ?? 'Test Task',
      totalTrackedSeconds: totalTrackedSeconds ?? 3600,
      hasActiveTimer: hasActiveTimer ?? false,
    );
  }

  /// Creates a test TaskHistoryDetail with default or custom values.
  static TaskHistoryDetail createTaskHistoryDetail({
    String? taskId,
    String? taskTitle,
    int? totalTrackedSeconds,
    bool? hasActiveTimer,
    List<TimeLog>? timeLogs,
  }) {
    return TaskHistoryDetail(
      taskId: taskId ?? 'task1',
      taskTitle: taskTitle ?? 'Test Task',
      totalTrackedSeconds: totalTrackedSeconds ?? 3600,
      hasActiveTimer: hasActiveTimer ?? false,
      timeLogs: timeLogs ?? [createTimeLog(taskId: taskId ?? 'task1')],
    );
  }

  /// Creates a list of test tasks.
  static List<Task> createTaskList({int count = 3}) {
    return List.generate(
      count,
      (index) => createTask(id: 'task$index', content: 'Test Task $index'),
    );
  }
}
