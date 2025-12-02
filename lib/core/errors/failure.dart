import 'package:equatable/equatable.dart';

/// Base class for all failure types in the application.
///
/// Failures represent error conditions that can occur during operations.
/// All failures are equatable and can carry additional properties for context.
abstract class Failure extends Equatable {
  /// Additional properties that provide context about the failure.
  final List<Object?> properties;

  /// Creates a [Failure] with optional [properties] for additional context.
  const Failure([this.properties = const <Object?>[]]);

  @override
  List<Object?> get props => properties;
}

/// Represents a failure that occurred on the server side.
///
/// This typically includes HTTP errors, API errors, or server-side validation failures.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with optional [properties] for additional context.
  const ServerFailure([super.properties]);
}

/// Represents a failure related to local cache or storage operations.
///
/// This includes failures when reading from or writing to local storage,
/// database errors, or cache corruption issues.
class CacheFailure extends Failure {
  /// Creates a [CacheFailure] with optional [properties] for additional context.
  const CacheFailure([super.properties]);
}

/// Represents a failure related to network connectivity or communication.
///
/// This includes connection timeouts, network unavailability, DNS failures,
/// or other network-related issues.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure] with optional [properties] for additional context.
  const NetworkFailure([super.properties]);
}
