import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_expense_modal_event.dart';
import 'add_expense_modal_state.dart';

/// Bloc that holds transient selection state for the AddExpense modal.
/// Keeps selectedCategory, selectedCurrency and selectedDate.
/// This allows the modal UI to be purely reactive (no setState).
class AddExpenseModalBloc
    extends Bloc<AddExpenseModalEvent, AddExpenseModalState> {
  AddExpenseModalBloc()
    : super(AddExpenseModalState(selectedDate: DateTime.now())) {
    on<SelectCategoryEvent>(_onSelectCategoryEvent);
    on<SelectCurrencyEvent>(_onSelectCurrencyEvent);
    on<SelectDateEvent>(_onSelectDateEvent);
    on<ResetAddExpenseModalEvent>(_onResetAddExpenseModalEvent);
  }

  void _onSelectCategoryEvent(
    SelectCategoryEvent event,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(state.copyWith(selectedCategory: event.category));
  }

  void _onSelectCurrencyEvent(
    SelectCurrencyEvent event,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(state.copyWith(selectedCurrency: event.currency));
  }

  void _onSelectDateEvent(
    SelectDateEvent event,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(state.copyWith(selectedDate: event.date));
  }

  void _onResetAddExpenseModalEvent(
    ResetAddExpenseModalEvent event,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(AddExpenseModalState(selectedDate: DateTime.now()));
  }
}
