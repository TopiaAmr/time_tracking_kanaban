import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final List<Object?> properties;

  const Failure([this.properties = const <Object?>[]]);

  @override
  List<Object?> get props => properties;
}

class ServerFailure extends Failure {
  const ServerFailure([super.properties]);
}

class CacheFailure extends Failure {
  const CacheFailure([super.properties]);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.properties]);
}
