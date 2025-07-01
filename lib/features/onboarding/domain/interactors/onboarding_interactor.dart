import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../repository.dart';

/// Interactor for onboarding business logic
/// Handles the coordination between repository and presentation layer
class OnboardingInteractor {
  final OnboardingRepository _repository;

  OnboardingInteractor() : _repository = getIt<OnboardingRepository>();

  /// Check if the application should show onboarding flow
  /// Returns true if this is the first launch and onboarding should be shown
  Future<Either<Failure, bool>> shouldShowOnboarding() async {
    final isFirstLaunchResult = await _repository.isFirstLaunch();
    
    return isFirstLaunchResult.fold(
      (failure) => Left(failure),
      (isFirstLaunch) async {
        if (!isFirstLaunch) {
          return const Right(false);
        }
        
        // Check if default categories are initialized
        final categoriesResult = await _repository.areDefaultCategoriesInitialized();
        return categoriesResult.fold(
          (failure) => Left(failure),
          (areInitialized) => Right(!areInitialized),
        );
      },
    );
  }

  /// Complete the onboarding process
  /// This should be called after user adds their first expense
  Future<Either<Failure, void>> completeOnboarding() async {
    // Mark first launch as completed
    final firstLaunchResult = await _repository.markFirstLaunchCompleted();
    if (firstLaunchResult.isLeft()) {
      return firstLaunchResult;
    }

    // Mark default categories as initialized
    final categoriesResult = await _repository.markDefaultCategoriesInitialized();
    return categoriesResult;
  }

  /// Reset onboarding state (useful for testing or app reset)
  Future<Either<Failure, void>> resetOnboarding() async {
    return await _repository.resetFirstLaunchFlag();
  }
}
