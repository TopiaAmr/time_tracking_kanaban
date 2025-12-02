import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Dependency injection module for preferences-related dependencies.
@module
abstract class PreferencesModule {
  /// Provides a SharedPreferences instance.
  ///
  /// Note: This must be initialized in main.dart before configureDependencies
  @preResolve
  @lazySingleton
  Future<SharedPreferences> get sharedPreferences async =>
      await SharedPreferences.getInstance();
}

