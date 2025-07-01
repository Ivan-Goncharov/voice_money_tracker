import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../repository.dart';

/// Interactor for category business logic
/// Handles the coordination between repository and presentation layer
class CategoryInteractor {
  final CategoryRepository _repository;

  CategoryInteractor() : _repository = getIt<CategoryRepository>();

  /// Get all active categories for display in UI
  Future<Either<Failure, List<CategoryEntity>>> getActiveCategories() async {
    return await _repository.getActiveCategories();
  }

  /// Get all categories (including inactive ones)
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories() async {
    return await _repository.getAllCategories();
  }

  /// Get a specific category by ID
  Future<Either<Failure, CategoryEntity?>> getCategoryById(int id) async {
    return await _repository.getCategoryById(id);
  }

  /// Create a new category
  Future<Either<Failure, int>> createCategory({
    required String name,
    String? description,
    required String color,
    required int iconCodePoint,
  }) async {
    final category = CategoriesCompanion.insert(
      name: name,
      description: Value(description),
      color: color,
      iconCodePoint: iconCodePoint,
    );

    return await _repository.insertCategory(category);
  }

  /// Update an existing category
  Future<Either<Failure, bool>> updateCategory({
    required int id,
    String? name,
    String? description,
    String? color,
    int? iconCodePoint,
    bool? isActive,
  }) async {
    final category = CategoriesCompanion(
      name: name != null ? Value(name) : const Value.absent(),
      description: description != null ? Value(description) : const Value.absent(),
      color: color != null ? Value(color) : const Value.absent(),
      iconCodePoint: iconCodePoint != null ? Value(iconCodePoint) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await _repository.updateCategory(id, category);
  }

  /// Deactivate a category (soft delete)
  Future<Either<Failure, bool>> deactivateCategory(int id) async {
    return await _repository.deactivateCategory(id);
  }

  /// Delete a category permanently
  Future<Either<Failure, int>> deleteCategory(int id) async {
    return await _repository.deleteCategory(id);
  }

  /// Watch active categories for real-time updates
  Stream<Either<Failure, List<CategoryEntity>>> watchActiveCategories() {
    return _repository.watchActiveCategories();
  }
}
