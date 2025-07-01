import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';

/// Repository interface for managing onboarding state
/// Handles first launch detection and user preferences
abstract interface class OnboardingRepository {
  /// Check if this is the first launch of the application
  /// Returns true if it's the first launch, false otherwise
  Future<Either<Failure, bool>> isFirstLaunch();

  /// Mark the first launch as completed
  /// This should be called after the user completes the onboarding flow
  Future<Either<Failure, void>> markFirstLaunchCompleted();

  /// Reset the first launch flag (useful for testing or reset functionality)
  Future<Either<Failure, void>> resetFirstLaunchFlag();

  /// Check if default categories have been initialized
  Future<Either<Failure, bool>> areDefaultCategoriesInitialized();

  /// Mark default categories as initialized
  Future<Either<Failure, void>> markDefaultCategoriesInitialized();
}
