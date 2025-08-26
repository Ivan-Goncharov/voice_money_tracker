part of 'category_bloc.dart';

enum CategoryOp { load, refresh, create, update, delete, search }
enum Status { idle, loading, success, failure }

/// Unified state with per-operation status/errors and live categories
class CategoryState extends Equatable {
  final List<CategoryEntity> _all; // raw list from DB
  final bool activeOnly;
  final String search;

  final Map<CategoryOp, Status> status;
  final Map<CategoryOp, Failure?> errors;

  const CategoryState({
    required List<CategoryEntity> all,
    required this.activeOnly,
    required this.search,
    this.status = const {},
    this.errors = const {},
  }) : _all = all;

  List<CategoryEntity> get categories {
    if (search.isEmpty) return _all;
    final q = search.toLowerCase().trim();
    return _all
        .where((c) => c.name.toLowerCase().contains(q) ||
            (c.description?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  bool busy(CategoryOp op) => status[op] == Status.loading;
  Failure? errorOf(CategoryOp op) => errors[op];

  CategoryState copyWith({
    List<CategoryEntity>? all,
    bool? activeOnly,
    String? search,
    Map<CategoryOp, Status>? status,
    Map<CategoryOp, Failure?>? errors,
  }) {
    return CategoryState(
      all: all ?? _all,
      activeOnly: activeOnly ?? this.activeOnly,
      search: search ?? this.search,
      status: status ?? this.status,
      errors: errors ?? this.errors,
    );
  }

  static CategoryState initial() => const CategoryState(
        all: <CategoryEntity>[],
        activeOnly: true,
        search: '',
        status: {},
        errors: {},
      );

  @override
  List<Object?> get props => [_all, activeOnly, search, status, errors];
}
