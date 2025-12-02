import 'package:equatable/equatable.dart';
import '../utils/result.dart';

/// Base class for all use cases in the application.
///
/// A use case represents a single business operation or action that can be
/// performed in the application. It encapsulates the business logic and
/// coordinates with repositories to perform operations.
///
/// Type parameters:
/// - [T]: The return type of the use case operation
/// - [Params]: The type of parameters required for the use case
///
/// Example:
/// ```dart
/// class GetTaskUseCase implements UseCase<Task, String> {
///   final TasksRepository repository;
///
///   GetTaskUseCase(this.repository);
///
///   @override
///   Future<Result<Task>> call(String taskId) async {
///     return await repository.getTask(taskId);
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  /// Executes the use case with the given [params].
  ///
  /// Returns a [Result] that can be either [Success] with the result value
  /// or [Error] with a [Failure] describing what went wrong.
  Future<Result<T>> call(Params params);
}

/// Parameter class for use cases that don't require any parameters.
///
/// Use this when a use case doesn't need any input parameters.
///
/// Example:
/// ```dart
/// class GetAllTasksUseCase implements UseCase<List<Task>, NoParams> {
///   @override
///   Future<Result<List<Task>>> call(NoParams params) async {
///     // Implementation
///   }
/// }
/// ```
class NoParams extends Equatable {
  /// Creates a [NoParams] instance.
  const NoParams();
  
  @override
  List<Object?> get props => [];
}
