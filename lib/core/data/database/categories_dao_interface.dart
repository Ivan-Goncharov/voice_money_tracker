import 'app_database.dart';

/// Interface for Categories Data Access Object
/// This abstraction allows repositories to work with categories data
/// without directly depending on Drift implementation details
abstract interface class CategoriesDaoInterface {
  /// Get all categories from the database
  Future<List<CategoryEntity>> getAllCategories();

  /// Get only active categories (isActive = true)
  Future<List<CategoryEntity>> getActiveCategories();

  /// Get a specific category by ID
  Future<CategoryEntity?> getCategoryById(int id);

  /// Insert a new category
  Future<int> insertCategory(CategoriesCompanion category);

  /// Update an existing category
  Future<bool> updateCategory(int id, CategoriesCompanion category);

  /// Delete a category permanently
  Future<int> deleteCategory(int id);

  /// Soft delete - deactivate a category instead of deleting
  Future<bool> deactivateCategory(int id);

  /// Watch active categories for real-time updates
  Stream<List<CategoryEntity>> watchActiveCategories();
}
