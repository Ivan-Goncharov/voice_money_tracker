import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/interactors/category_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../../core/error/failures.dart';

part 'category_event.dart';
part 'category_state.dart';

/// BLoC for managing category operations
/// Handles loading, creating, updating, and deleting categories
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryInteractor _interactor;
  StreamSubscription<Either<Failure, List<CategoryEntity>>>?
  _categoriesSubscription;

  CategoryBloc()
    : _interactor = getIt<CategoryInteractor>(),
      super(const CategoryInitial()) {
    on<LoadActiveCategories>((event, emit) => _onLoadActiveCategories(emit));
    on<LoadAllCategories>((event, emit) => _onLoadAllCategories(emit));
    on<CreateCategory>(
      (event, emit) => _onCreateCategory(
        emit,
        event.name,
        event.description,
        event.color,
        event.iconCodePoint,
      ),
    );
    on<UpdateCategory>(
      (event, emit) => _onUpdateCategory(
        emit,
        event.id,
        event.name,
        event.description,
        event.color,
        event.iconCodePoint,
        event.isActive,
      ),
    );
    on<DeactivateCategory>(
      (event, emit) => _onDeactivateCategory(emit, event.id),
    );
    on<DeleteCategory>((event, emit) => _onDeleteCategory(emit, event.id));
    on<StartWatchingCategories>(
      (event, emit) => _onStartWatchingCategories(emit),
    );
    on<StopWatchingCategories>(
      (event, emit) => _onStopWatchingCategories(emit),
    );
  }

  @override
  Future<void> close() {
    _categoriesSubscription?.cancel();
    return super.close();
  }

  /// Handle loading active categories
  Future<void> _onLoadActiveCategories(Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());

    final result = await _interactor.getActiveCategories();

    result.fold(
      (failure) => emit(CategoryError(message: failure.message)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  /// Handle loading all categories
  Future<void> _onLoadAllCategories(Emitter<CategoryState> emit) async {
    emit(const CategoryLoading());

    final result = await _interactor.getAllCategories();

    result.fold(
      (failure) => emit(CategoryError(message: failure.message)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  /// Handle creating a new category
  Future<void> _onCreateCategory(
    Emitter<CategoryState> emit,
    String name,
    String? description,
    String color,
    int iconCodePoint,
  ) async {
    emit(const CategoryLoading());

    final result = await _interactor.createCategory(
      name: name,
      description: description,
      color: color,
      iconCodePoint: iconCodePoint,
    );

    await result.fold(
      (failure) async => emit(CategoryError(message: failure.message)),
      (categoryId) async {
        // Reload categories after creation
        final categoriesResult = await _interactor.getActiveCategories();
        categoriesResult.fold(
          (failure) => emit(CategoryError(message: failure.message)),
          (categories) => emit(
            CategoryCreated(categoryId: categoryId, categories: categories),
          ),
        );
      },
    );
  }

  /// Handle updating a category
  Future<void> _onUpdateCategory(
    Emitter<CategoryState> emit,
    int id,
    String? name,
    String? description,
    String? color,
    int? iconCodePoint,
    bool? isActive,
  ) async {
    emit(const CategoryLoading());

    final result = await _interactor.updateCategory(
      id: id,
      name: name,
      description: description,
      color: color,
      iconCodePoint: iconCodePoint,
      isActive: isActive,
    );

    await result.fold(
      (failure) async => emit(CategoryError(message: failure.message)),
      (success) async {
        if (success) {
          // Reload categories after update
          final categoriesResult = await _interactor.getActiveCategories();
          categoriesResult.fold(
            (failure) => emit(CategoryError(message: failure.message)),
            (categories) => emit(CategoryUpdated(categories: categories)),
          );
        } else {
          emit(const CategoryError(message: 'Failed to update category'));
        }
      },
    );
  }

  /// Handle deactivating a category
  Future<void> _onDeactivateCategory(
    Emitter<CategoryState> emit,
    int id,
  ) async {
    emit(const CategoryLoading());

    final result = await _interactor.deactivateCategory(id);

    await result.fold(
      (failure) async => emit(CategoryError(message: failure.message)),
      (success) async {
        if (success) {
          // Reload categories after deactivation
          final categoriesResult = await _interactor.getActiveCategories();
          categoriesResult.fold(
            (failure) => emit(CategoryError(message: failure.message)),
            (categories) => emit(CategoryDeleted(categories: categories)),
          );
        } else {
          emit(const CategoryError(message: 'Failed to deactivate category'));
        }
      },
    );
  }

  /// Handle deleting a category permanently
  Future<void> _onDeleteCategory(Emitter<CategoryState> emit, int id) async {
    emit(const CategoryLoading());

    final result = await _interactor.deleteCategory(id);

    await result.fold(
      (failure) async => emit(CategoryError(message: failure.message)),
      (deletedCount) async {
        if (deletedCount > 0) {
          // Reload categories after deletion
          final categoriesResult = await _interactor.getActiveCategories();
          categoriesResult.fold(
            (failure) => emit(CategoryError(message: failure.message)),
            (categories) => emit(CategoryDeleted(categories: categories)),
          );
        } else {
          emit(const CategoryError(message: 'Failed to delete category'));
        }
      },
    );
  }

  /// Handle starting to watch categories for real-time updates
  Future<void> _onStartWatchingCategories(Emitter<CategoryState> emit) async {
    await _categoriesSubscription?.cancel();

    _categoriesSubscription = _interactor.watchActiveCategories().listen((
      result,
    ) {
      result.fold(
        (failure) => emit(CategoryError(message: failure.message)),
        (categories) =>
            emit(CategoryLoaded(categories: categories, isWatching: true)),
      );
    });
  }

  /// Handle stopping watching categories
  Future<void> _onStopWatchingCategories(Emitter<CategoryState> emit) async {
    await _categoriesSubscription?.cancel();
    _categoriesSubscription = null;

    // Keep current categories but mark as not watching
    final currentState = state;
    if (currentState is CategoryLoaded) {
      emit(
        CategoryLoaded(categories: currentState.categories, isWatching: false),
      );
    }
  }
}
