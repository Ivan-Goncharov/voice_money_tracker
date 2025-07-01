part of 'category_bloc.dart';

/// Events for CategoryBloc
/// Represents all possible user actions and system events for categories
sealed class CategoryEvent {
  const CategoryEvent();
}

/// Load all active categories
final class LoadActiveCategories extends CategoryEvent {
  const LoadActiveCategories();
}

/// Load all categories (including inactive)
final class LoadAllCategories extends CategoryEvent {
  const LoadAllCategories();
}

/// Create a new category
final class CreateCategory extends CategoryEvent {
  const CreateCategory({
    required this.name,
    this.description,
    required this.color,
    required this.iconCodePoint,
  });

  final String name;
  final String? description;
  final String color;
  final int iconCodePoint;
}

/// Update an existing category
final class UpdateCategory extends CategoryEvent {
  const UpdateCategory({
    required this.id,
    this.name,
    this.description,
    this.color,
    this.iconCodePoint,
    this.isActive,
  });

  final int id;
  final String? name;
  final String? description;
  final String? color;
  final int? iconCodePoint;
  final bool? isActive;
}

/// Deactivate a category (soft delete)
final class DeactivateCategory extends CategoryEvent {
  const DeactivateCategory(this.id);

  final int id;
}

/// Delete a category permanently
final class DeleteCategory extends CategoryEvent {
  const DeleteCategory(this.id);

  final int id;
}

/// Start watching categories for real-time updates
final class StartWatchingCategories extends CategoryEvent {
  const StartWatchingCategories();
}

/// Stop watching categories
final class StopWatchingCategories extends CategoryEvent {
  const StopWatchingCategories();
}
