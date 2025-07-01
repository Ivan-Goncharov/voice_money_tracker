part of 'category_bloc.dart';

/// States for CategoryBloc
/// Represents all possible states during category operations
sealed class CategoryState {
  const CategoryState();
}

/// Initial state when the bloc is created
final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Loading state while performing category operations
final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// State with loaded categories
final class CategoryLoaded extends CategoryState {
  const CategoryLoaded({required this.categories, this.isWatching = false});

  final List<CategoryEntity> categories;
  final bool isWatching;
}

/// State indicating successful category creation
final class CategoryCreated extends CategoryState {
  const CategoryCreated({required this.categoryId, required this.categories});

  final int categoryId;
  final List<CategoryEntity> categories;
}

/// State indicating successful category update
final class CategoryUpdated extends CategoryState {
  const CategoryUpdated({required this.categories});

  final List<CategoryEntity> categories;
}

/// State indicating successful category deletion/deactivation
final class CategoryDeleted extends CategoryState {
  const CategoryDeleted({required this.categories});

  final List<CategoryEntity> categories;
}

/// Error state when something goes wrong
final class CategoryError extends CategoryState {
  const CategoryError({required this.message, this.categories});

  final String message;
  final List<CategoryEntity>? categories;
}
