import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/service_locator/service_locator.dart';
import '../../../core/data/database/database.dart';
import '../domain/repository.dart';

/// Implementation of CategoryRepository using Drift database
/// Handles all category-related database operations
class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _database;

  CategoryRepositoryImpl() : _database = getIt<AppDatabase>();

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    try {
      final categories = await _database.categoriesDao.getAllCategories();
      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories() async {
    try {
      final categories = await _database.categoriesDao.getActiveCategories();
      return Right(categories);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active categories: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CategoryEntity?>> getCategoryById(int id) async {
    try {
      final category = await _database.categoriesDao.getCategoryById(id);
      return Right(category);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get category by ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> insertCategory(CategoriesCompanion category) async {
    try {
      final id = await _database.categoriesDao.insertCategory(category);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to insert category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCategory(int id, CategoriesCompanion category) async {
    try {
      final success = await _database.categoriesDao.updateCategory(id, category);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteCategory(int id) async {
    try {
      final deletedCount = await _database.categoriesDao.deleteCategory(id);
      return Right(deletedCount);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> deactivateCategory(int id) async {
    try {
      final success = await _database.categoriesDao.deactivateCategory(id);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure('Failed to deactivate category: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<CategoryEntity>>> watchActiveCategories() {
    try {
      return _database.categoriesDao.watchActiveCategories().map(
        (categories) => Right<Failure, List<CategoryEntity>>(categories),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch active categories: ${e.toString()}')),
      );
    }
  }
}
