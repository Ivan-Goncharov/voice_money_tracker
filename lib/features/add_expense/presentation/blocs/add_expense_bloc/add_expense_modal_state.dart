import 'package:equatable/equatable.dart';
import 'package:money_tracker_2/core/data/database/app_database.dart'
    show CategoryEntity, CurrencyEntity;
import 'package:money_tracker_2/core/error/failures.dart';

enum Op { create }

enum ExpenseStatus { idle, loading, success, failure }

class AddExpenseModalState extends Equatable {
  final CategoryEntity? selectedCategory;
  final CurrencyEntity? selectedCurrency;
  final DateTime selectedDate;

  final Map<Op, ExpenseStatus> status;
  final Map<Op, Failure?> errors;
  final int? createdExpenseId;

  const AddExpenseModalState({
    this.selectedCategory,
    this.selectedCurrency,
    required this.selectedDate,
    this.status = const {},
    this.errors = const {},
    this.createdExpenseId,
  });

  bool busy(Op op) => status[op] == ExpenseStatus.loading;
  Failure? errorOf(Op op) => errors[op];

  AddExpenseModalState copyWith({
    CategoryEntity? Function()? selectedCategory,
    CurrencyEntity? Function()? selectedCurrency,
    DateTime? selectedDate,
    Map<Op, ExpenseStatus>? status,
    Map<Op, Failure?>? errors,
    int? Function()? createdExpenseId,
  }) {
    return AddExpenseModalState(
      selectedCategory:
          selectedCategory != null ? selectedCategory() : this.selectedCategory,
      selectedCurrency:
          selectedCurrency != null ? selectedCurrency() : this.selectedCurrency,
      selectedDate: selectedDate ?? this.selectedDate,
      status: status ?? this.status,
      errors: errors ?? this.errors,
      createdExpenseId:
          createdExpenseId != null ? createdExpenseId() : this.createdExpenseId,
    );
  }

  @override
  List<Object?> get props => [
    selectedCategory,
    selectedCurrency,
    selectedDate,
    status,
    errors,
    createdExpenseId,
  ];

  static AddExpenseModalState initial() => AddExpenseModalState(
    selectedDate: DateTime.now(),
    status: const {},
    errors: const {},
  );
}
