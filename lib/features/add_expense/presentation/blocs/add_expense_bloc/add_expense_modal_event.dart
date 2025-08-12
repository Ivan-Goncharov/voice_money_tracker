import 'package:equatable/equatable.dart';
import 'package:money_tracker_2/core/data/database/app_database.dart'
    show CategoryEntity, CurrencyEntity;

sealed class AddExpenseModalEvent extends Equatable {
  const AddExpenseModalEvent();
}

final class SelectCategoryEvent extends AddExpenseModalEvent {
  final CategoryEntity category;

  const SelectCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

final class SelectCurrencyEvent extends AddExpenseModalEvent {
  final CurrencyEntity currency;

  const SelectCurrencyEvent(this.currency);

  @override
  List<Object?> get props => [currency];
}

final class SelectDateEvent extends AddExpenseModalEvent {
  final DateTime date;

  const SelectDateEvent(this.date);

  @override
  List<Object?> get props => [date];
}

final class ResetAddExpenseModalEvent extends AddExpenseModalEvent {
  const ResetAddExpenseModalEvent();

  @override
  List<Object?> get props => [];
}
