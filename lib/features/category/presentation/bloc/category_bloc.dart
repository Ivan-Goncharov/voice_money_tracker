import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart' as bc;
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart' as rx;
import '../../domain/interactors/category_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../../core/error/failures.dart';

part 'category_event.dart';
part 'category_state.dart';

/// CategoryBloc with permanent Drift subscription and unified state
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryInteractor _interactor;

  StreamSubscription<Either<Failure, List<CategoryEntity>>>? _sub;

  CategoryBloc()
      : _interactor = getIt<CategoryInteractor>(),
        super(CategoryState.initial()) {
    // Permanent subscription: forward interactor stream into internal events
    _sub = _interactor.categories$.listen((either) {
      add(_CategoriesStreamUpdated(either));
    });

    on<_CategoriesStreamUpdated>(_onCategoriesUpdated, transformer: bc.droppable());

    on<CategoriesFilterChanged>(
      _onFilterChanged,
      transformer: bc.restartable(),
    );

    on<CategorySearchChanged>(
      _onSearchChanged,
      transformer: _debounce(const Duration(milliseconds: 400)),
    );

    on<CategoryCreateRequested>(
      _onCreateRequested,
      transformer: bc.concurrent(),
    );

    on<CategoryUpdatedRequested>(
      _onUpdatedRequested,
      transformer: bc.concurrent(),
    );

    on<CategoryDeactivatedRequested>(
      _onDeactivatedRequested,
      transformer: bc.concurrent(),
    );

    on<CategoryDeletedRequested>(
      _onDeletedRequested,
      transformer: bc.concurrent(),
    );
  }

  // Rx-based debounce transformer for search
  EventTransformer<T> _debounce<T>(Duration d) {
    return (events, mapper) => events.debounceTime(d).switchMap(mapper);
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }

  // Handlers
  void _onCategoriesUpdated(
    _CategoriesStreamUpdated e,
    Emitter<CategoryState> emit,
  ) {
    e.payload.fold(
      (failure) => emit(
        state.copyWith(
          status: {...state.status, CategoryOp.load: Status.failure},
          errors: {...state.errors, CategoryOp.load: failure},
          all: const <CategoryEntity>[],
        ),
      ),
      (categories) => emit(
        state.copyWith(
          status: {...state.status, CategoryOp.load: Status.success},
          errors: {...state.errors, CategoryOp.load: null},
          all: categories,
        ),
      ),
    );
  }

  void _onFilterChanged(
    CategoriesFilterChanged e,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(activeOnly: e.activeOnly));
    _interactor.setActiveOnly(e.activeOnly);
  }

  void _onSearchChanged(
    CategorySearchChanged e,
    Emitter<CategoryState> emit,
  ) {
    emit(state.copyWith(
      search: e.query,
      status: {...state.status, CategoryOp.search: Status.success},
      errors: {...state.errors, CategoryOp.search: null},
    ));
  }

  Future<void> _onCreateRequested(
    CategoryCreateRequested e,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(
      status: {...state.status, CategoryOp.create: Status.loading},
      errors: {...state.errors, CategoryOp.create: null},
    ));
    final result = await _interactor.createCategory(
      name: e.name,
      description: e.description,
      color: e.color,
      iconCodePoint: e.iconCodePoint,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: {...state.status, CategoryOp.create: Status.failure},
        errors: {...state.errors, CategoryOp.create: failure},
      )),
      (_) => emit(state.copyWith(
        status: {...state.status, CategoryOp.create: Status.success},
      )),
    );
  }

  Future<void> _onUpdatedRequested(
    CategoryUpdatedRequested e,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(
      status: {...state.status, CategoryOp.update: Status.loading},
      errors: {...state.errors, CategoryOp.update: null},
    ));
    final result = await _interactor.updateCategory(
      id: e.id,
      name: e.name,
      description: e.description,
      color: e.color,
      iconCodePoint: e.iconCodePoint,
      isActive: e.isActive,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: {...state.status, CategoryOp.update: Status.failure},
        errors: {...state.errors, CategoryOp.update: failure},
      )),
      (_) => emit(state.copyWith(
        status: {...state.status, CategoryOp.update: Status.success},
      )),
    );
  }

  Future<void> _onDeactivatedRequested(
    CategoryDeactivatedRequested e,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(
      status: {...state.status, CategoryOp.delete: Status.loading},
      errors: {...state.errors, CategoryOp.delete: null},
    ));
    final result = await _interactor.deactivateCategory(e.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: {...state.status, CategoryOp.delete: Status.failure},
        errors: {...state.errors, CategoryOp.delete: failure},
      )),
      (_) => emit(state.copyWith(
        status: {...state.status, CategoryOp.delete: Status.success},
      )),
    );
  }

  Future<void> _onDeletedRequested(
    CategoryDeletedRequested e,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(
      status: {...state.status, CategoryOp.delete: Status.loading},
      errors: {...state.errors, CategoryOp.delete: null},
    ));
    final result = await _interactor.deleteCategory(e.id);
    result.fold(
      (failure) => emit(state.copyWith(
        status: {...state.status, CategoryOp.delete: Status.failure},
        errors: {...state.errors, CategoryOp.delete: failure},
      )),
      (_) => emit(state.copyWith(
        status: {...state.status, CategoryOp.delete: Status.success},
      )),
    );
  }
}
