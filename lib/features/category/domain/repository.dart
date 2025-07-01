import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/data/database/database.dart';

/// Repository interface for managing categories
/// Provides abstraction over data layer for category operations
abstract interface class CategoryRepository {
  /// Get all categories from the database
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories();

  /// Get only active categories (isActive = true)
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories();

  /// Get a specific category by ID
  Future<Either<Failure, CategoryEntity?>> getCategoryById(int id);

  /// Insert a new category
  Future<Either<Failure, int>> insertCategory(CategoriesCompanion category);

  /// Update an existing category
  Future<Either<Failure, bool>> updateCategory(int id, CategoriesCompanion category);

  /// Delete a category permanently
  Future<Either<Failure, int>> deleteCategory(int id);

  /// Soft delete - deactivate a category instead of deleting
  Future<Either<Failure, bool>> deactivateCategory(int id);

  /// Watch active categories for real-time updates
  Stream<Either<Failure, List<CategoryEntity>>> watchActiveCategories();
}
