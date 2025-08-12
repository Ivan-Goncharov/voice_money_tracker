import 'package:equatable/equatable.dart';
import 'package:money_tracker_2/core/data/database/app_database.dart'
    show CategoryEntity, CurrencyEntity;

class AddExpenseModalState extends Equatable {
  final CategoryEntity? selectedCategory;
  final CurrencyEntity? selectedCurrency;
  final DateTime selectedDate;

  const AddExpenseModalState({
    this.selectedCategory,
    this.selectedCurrency,
    required this.selectedDate,
  });

  AddExpenseModalState copyWith({
    CategoryEntity? selectedCategory,
    CurrencyEntity? selectedCurrency,
    DateTime? selectedDate,
  }) {
    return AddExpenseModalState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [selectedCategory, selectedCurrency, selectedDate];

  @override
  String toString() =>
      'AddExpenseModalState(selectedCategory: $selectedCategory, selectedCurrency: $selectedCurrency, selectedDate: $selectedDate)';
}
