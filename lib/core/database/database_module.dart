import 'package:injectable/injectable.dart';
import 'package:time_tracking_kanaban/core/database/app_database.dart';

/// Dependency injection module for database-related dependencies.
///
/// This module provides singleton instances of:
/// - [AppDatabase]: Drift database instance for local storage
@module
abstract class DatabaseModule {
  /// Provides a configured [AppDatabase] instance.
  ///
  /// The database is initialized with the schema defined in [AppDatabase]
  /// and stored in the application documents directory.
  ///
  /// Returns a lazy singleton instance that is created on first access.
  @lazySingleton
  AppDatabase get appDatabase => AppDatabase();
}
