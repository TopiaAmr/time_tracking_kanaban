import 'package:time_tracking_kanaban/core/errors/failure.dart';

/// Sealed class for strict Success OR Failure handling.
///
/// This is a type-safe way to represent the result of an operation that can
/// either succeed with a value of type [T] or fail with a [Failure].
///
/// Using a sealed class ensures exhaustive pattern matching and prevents
/// null-related errors. All operations in the application should return
/// a [Result] to handle errors explicitly.
///
/// Example:
/// ```dart
/// Result<String> result = await someOperation();
/// result.when(
///   success: (value) => print('Success: $value'),
///   error: (failure) => print('Error: $failure'),
/// );
/// ```
sealed class Result<T> {
  /// Creates a [Result] instance.
  const Result();
}

/// Represents a successful operation result.
///
/// Contains the [value] that was produced by the successful operation.
final class Success<T> extends Result<T> {
  /// The successful result value.
  final T value;
  
  /// Creates a [Success] result with the given [value].
  const Success(this.value);
}

/// Represents a failed operation result.
///
/// Contains the [failure] that describes what went wrong during the operation.
final class Error<T> extends Result<T> {
  /// The failure that occurred during the operation.
  final Failure failure;
  
  /// Creates an [Error] result with the given [failure].
  const Error(this.failure);
}
