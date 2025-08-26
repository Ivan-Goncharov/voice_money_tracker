import 'package:equatable/equatable.dart';
import 'package:money_tracker_2/core/data/database/app_database.dart'
    show CategoryEntity, CurrencyEntity;

sealed class AddExpenseModalEvent extends Equatable {
  const AddExpenseModalEvent();
}

final class AddExpenseCategorySelected extends AddExpenseModalEvent {
  final CategoryEntity category;
  const AddExpenseCategorySelected(this.category);
  @override
  List<Object?> get props => [category];
}

final class AddExpenseCurrencySelected extends AddExpenseModalEvent {
  final CurrencyEntity currency;
  const AddExpenseCurrencySelected(this.currency);
  @override
  List<Object?> get props => [currency];
}

final class AddExpenseDateSelected extends AddExpenseModalEvent {
  final DateTime date;
  const AddExpenseDateSelected(this.date);
  @override
  List<Object?> get props => [date];
}

final class AddExpenseResetRequested extends AddExpenseModalEvent {
  const AddExpenseResetRequested();
  @override
  List<Object?> get props => [];
}

final class AddExpenseSubmitted extends AddExpenseModalEvent {
  final double amount;
  final String? description;
  final int categoryId;
  final DateTime date;
  final int? currencyId;
  final String? notes;

  const AddExpenseSubmitted({
    required this.amount,
    this.description,
    required this.categoryId,
    required this.date,
    this.currencyId,
    this.notes,
  });

  @override
  List<Object?> get props => [
    amount,
    description,
    categoryId,
    date,
    currencyId,
    notes,
  ];
}
