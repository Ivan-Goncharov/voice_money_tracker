import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/failures.dart';
import '../../../core/service_locator/service_locator.dart';
import '../domain/repository.dart';

/// Implementation of OnboardingRepository using SharedPreferences
/// Handles persistence of onboarding state and first launch detection
class OnboardingRepositoryImpl implements OnboardingRepository {
  static const String _firstLaunchKey = 'is_first_launch';
  static const String _defaultCategoriesInitializedKey =
      'default_categories_initialized';

  final SharedPreferences _prefs;

  OnboardingRepositoryImpl() : _prefs = getIt<SharedPreferences>();

  @override
  Future<Either<Failure, bool>> isFirstLaunch() async {
    try {
      // If the key doesn't exist, it means this is the first launch
      final isFirstLaunch = _prefs.getBool(_firstLaunchKey) ?? true;
      return Right(isFirstLaunch);
    } catch (e) {
      return Left(
        StorageFailure('Failed to check first launch status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markFirstLaunchCompleted() async {
    try {
      final success = await _prefs.setBool(_firstLaunchKey, false);
      if (success) {
        return const Right(null);
      } else {
        return const Left(
          StorageFailure('Failed to mark first launch as completed'),
        );
      }
    } catch (e) {
      return Left(
        StorageFailure(
          'Failed to mark first launch as completed: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> resetFirstLaunchFlag() async {
    try {
      final success = await _prefs.setBool(_firstLaunchKey, true);
      if (success) {
        // Also reset the default categories flag
        await _prefs.setBool(_defaultCategoriesInitializedKey, false);
        return const Right(null);
      } else {
        return const Left(StorageFailure('Failed to reset first launch flag'));
      }
    } catch (e) {
      return Left(
        StorageFailure('Failed to reset first launch flag: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> areDefaultCategoriesInitialized() async {
    try {
      final areInitialized =
          _prefs.getBool(_defaultCategoriesInitializedKey) ?? false;
      return Right(areInitialized);
    } catch (e) {
      return Left(
        StorageFailure(
          'Failed to check default categories status: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> markDefaultCategoriesInitialized() async {
    try {
      final success = await _prefs.setBool(
        _defaultCategoriesInitializedKey,
        true,
      );
      if (success) {
        return const Right(null);
      } else {
        return const Left(
          StorageFailure('Failed to mark default categories as initialized'),
        );
      }
    } catch (e) {
      return Left(
        StorageFailure(
          'Failed to mark default categories as initialized: ${e.toString()}',
        ),
      );
    }
  }
}
