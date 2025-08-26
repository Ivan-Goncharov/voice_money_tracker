part of 'category_bloc.dart';

/// Events for CategoryBloc (past-tense, specific)
sealed class CategoryEvent {
  const CategoryEvent();
}

/// Internal: categories stream pushed a new value
final class _CategoriesStreamUpdated extends CategoryEvent {
  const _CategoriesStreamUpdated(this.payload);
  final Either<Failure, List<CategoryEntity>> payload;
}

/// Filter toggled (active-only or all)
final class CategoriesFilterChanged extends CategoryEvent {
  const CategoriesFilterChanged(this.activeOnly);
  final bool activeOnly;
}

/// Search query changed
final class CategorySearchChanged extends CategoryEvent {
  const CategorySearchChanged(this.query);
  final String query;
}

/// Create requested
final class CategoryCreateRequested extends CategoryEvent {
  const CategoryCreateRequested({
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

/// Update requested
final class CategoryUpdatedRequested extends CategoryEvent {
  const CategoryUpdatedRequested({
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

/// Deactivate requested (soft delete)
final class CategoryDeactivatedRequested extends CategoryEvent {
  const CategoryDeactivatedRequested(this.id);
  final int id;
}

/// Delete requested (hard delete)
final class CategoryDeletedRequested extends CategoryEvent {
  const CategoryDeletedRequested(this.id);
  final int id;
}
