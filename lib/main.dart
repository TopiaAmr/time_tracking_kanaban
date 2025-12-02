import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_cubit.dart';
import 'package:time_tracking_kanaban/core/l10n/l10n_state.dart';
import 'package:time_tracking_kanaban/core/navigation/app_router.dart';
import 'package:time_tracking_kanaban/core/theme/app_theme.dart';
import 'package:time_tracking_kanaban/core/theme/theme_cubit.dart';
import 'package:time_tracking_kanaban/core/theme/theme_state.dart';
import 'package:time_tracking_kanaban/core/widgets/floating_timer_widget.dart';
import 'package:time_tracking_kanaban/di.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_bloc.dart';
import 'package:time_tracking_kanaban/features/timer/presentation/bloc/timer_event.dart';
import 'package:time_tracking_kanaban/l10n/app_localizations.dart';

/// Entry point of the application.
///
/// Initializes Flutter bindings, loads environment variables,
/// configures dependency injection, and runs the application.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables from .env file
  await dotenv.load(fileName: '.env');
  
  // Configure dependencies (this will register SharedPreferences via PreferencesModule)
  await configureDependencies();
  
  runApp(MyApp());
}

/// Root widget of the application.
///
/// This widget configures the Material app with theme, localization,
/// routing, and state management.
class MyApp extends StatelessWidget {
  /// Creates a [MyApp] instance.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme management - get from DI
        BlocProvider(
          create: (context) => getIt<ThemeCubit>(),
        ),
        // Locale management - get from DI
        BlocProvider(
          create: (context) => getIt<L10nCubit>(),
        ),
        // Timer management - global for timer widget and task detail
        BlocProvider.value(
          value: getIt<TimerBloc>()..add(const LoadActiveTimer()),
        ),
      ],
      child: BlocBuilder<L10nCubit, L10nState>(
        builder: (context, l10nState) {
          return BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, themeState) {
              final router = AppRouter.createRouter();
              
              return MaterialApp.router(
                title: 'Kanva',
                debugShowCheckedModeBanner: false,
                
                // Theme configuration
                theme: AppTheme.lightTheme(themeState),
                darkTheme: AppTheme.darkTheme(themeState),
                themeMode: themeState.themeMode == ThemeModeType.light
                    ? ThemeMode.light
                    : themeState.themeMode == ThemeModeType.dark
                        ? ThemeMode.dark
                        : ThemeMode.system,
                
                // Localization configuration
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                locale: l10nState.locale,
                
                // Router configuration
                routerConfig: router,
                
                // Builder to add persistent floating timer on top of all screens
                builder: (context, child) {
                  return Overlay(
                    initialEntries: [
                      OverlayEntry(
                        builder: (context) => child ?? const SizedBox.shrink(),
                      ),
                      OverlayEntry(
                        builder: (context) => Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: SafeArea(
                            child: Center(
                              child: FloatingTimerWidget(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
