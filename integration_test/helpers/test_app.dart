import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_cubit.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_state.dart';
import 'package:time_tracking_kanaban/core/navigation/app_router.dart';
import 'package:time_tracking_kanaban/core/theme/app_theme.dart';
import 'package:time_tracking_kanaban/core/theme/theme_cubit.dart';
import 'package:time_tracking_kanaban/core/theme/theme_state.dart';
import 'package:time_tracking_kanaban/features/tasks/presentation/bloc/kanban_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'package:time_tracking_kanaban/l10n/app_localizations.dart';
import 'package:time_tracking_kanaban/di.dart';

/// Test app wrapper for integration tests.
///
/// Provides a configured app with real dependencies for E2E testing.
/// For integration tests, we use the real app with real DI setup.
class TestApp extends StatelessWidget {
  final Widget? child;
  final bool useRouter;

  const TestApp({
    super.key,
    this.child,
    this.useRouter = true,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme management - get from DI (same as main.dart)
        BlocProvider<ThemeCubit>(
          create: (context) => getIt<ThemeCubit>(),
        ),
        // Locale management - get from DI (same as main.dart)
        BlocProvider<L10nCubit>(
          create: (context) => getIt<L10nCubit>(),
        ),
        // Timer management - global for timer widget and task detail
        BlocProvider<TimerBloc>.value(
          value: getIt<TimerBloc>()..add(const LoadActiveTimer()),
        ),
        // Kanban bloc for task management
        BlocProvider<KanbanBloc>.value(
          value: getIt<KanbanBloc>(),
        ),
      ],
      child: BlocBuilder<L10nCubit, L10nState>(
        builder: (context, l10nState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              if (useRouter) {
                final router = AppRouter.createRouter();
                return MaterialApp.router(
                  title: 'Kanva Test',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme(themeState),
                  darkTheme: AppTheme.darkTheme(themeState),
                  themeMode: themeState.themeMode == ThemeModeType.light
                      ? ThemeMode.light
                      : themeState.themeMode == ThemeModeType.dark
                          ? ThemeMode.dark
                          : ThemeMode.system,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: l10nState.locale,
                  routerConfig: router,
                );
              } else {
                return MaterialApp(
                  title: 'Kanva Test',
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.lightTheme(themeState),
                  darkTheme: AppTheme.darkTheme(themeState),
                  themeMode: themeState.themeMode == ThemeModeType.light
                      ? ThemeMode.light
                      : themeState.themeMode == ThemeModeType.dark
                          ? ThemeMode.dark
                          : ThemeMode.system,
                  localizationsDelegates: AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  locale: l10nState.locale,
                  home: child,
                );
              }
            },
          );
        },
      ),
    );
  }
}

/// Helper class for setting up and tearing down integration test dependencies.
class IntegrationTestHelper {
  static bool _isInitialized = false;

  /// Initializes dependencies once for all tests.
  static Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await configureDependencies();
      _isInitialized = true;
    }
  }

  /// Resets the DI container for a fresh test run.
  /// Call this in tearDown if you need isolated tests.
  static Future<void> resetDependencies() async {
    await getIt.reset();
    _isInitialized = false;
  }

  /// Pumps the app and waits for it to settle.
  static Future<void> pumpApp(
    WidgetTester tester, {
    Widget? child,
    bool useRouter = true,
    Duration? settleTimeout,
  }) async {
    await ensureInitialized();
    
    await tester.pumpWidget(
      TestApp(
        useRouter: useRouter,
        child: child,
      ),
    );
    
    // Use a try-catch to handle pumpAndSettle timeout gracefully
    try {
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        settleTimeout ?? const Duration(seconds: 10),
      );
    } catch (e) {
      // If pumpAndSettle times out, just pump a few more frames
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  /// Waits for async operations to complete.
  static Future<void> waitForAsync(WidgetTester tester, {Duration? duration}) async {
    await tester.pump(duration ?? const Duration(milliseconds: 100));
    try {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
    } catch (e) {
      // Ignore timeout errors
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Waits for a specific duration (useful for timer tests).
  static Future<void> wait(WidgetTester tester, Duration duration) async {
    await tester.pump(duration);
  }

  /// Cleans up after a test by pumping remaining frames.
  /// Call this at the end of each test to allow pending async operations to complete.
  static Future<void> cleanUp(WidgetTester tester) async {
    // Pump a few frames to allow pending operations to complete or fail gracefully
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
  }
}
