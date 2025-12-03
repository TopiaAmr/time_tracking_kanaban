import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/comments_repository.dart';
import 'package:time_tracking_kanaban/features/tasks/domain/repository/tasks_repository.dart';
import 'package:time_tracking_kanaban/features/timer/domain/repository/timer_repository.dart';

/// Generate mocks for integration tests.
///
/// Run: flutter pub run build_runner build --delete-conflicting-outputs
@GenerateMocks([
  TasksRepository,
  CommentsRepository,
  TimerRepository,
  SharedPreferences,
])
void main() {}
