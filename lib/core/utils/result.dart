import 'package:time_tracking_kanaban/core/errors/failure.dart';

/// Sealed class for strict Success OR Failure handling
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
