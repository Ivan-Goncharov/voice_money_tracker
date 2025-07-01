import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
/// Uses functional programming approach with Dartz for error handling
abstract class Failure extends Equatable {
  final String message;
  
  const Failure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// Failure when there's an issue with local storage (SharedPreferences)
class StorageFailure extends Failure {
  const StorageFailure([String message = 'Storage error occurred']) : super(message);
}

/// Failure when there's an issue with database operations
class DatabaseFailure extends Failure {
  const DatabaseFailure([String message = 'Database error occurred']) : super(message);
}

/// Failure when there's a network connectivity issue
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) : super(message);
}

/// Failure when validation fails
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation failed']) : super(message);
}

/// Failure when a requested resource is not found
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}

/// Failure for unexpected/unknown errors
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unknown error occurred']) : super(message);
}
