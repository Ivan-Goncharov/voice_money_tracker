import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_2/core/service_locator/service_locator.dart';
import 'package:money_tracker_2/features/expense/domain/interactors/expense_interactor.dart';
import 'add_expense_modal_event.dart';
import 'add_expense_modal_state.dart';

/// AddExpense modal BLoC following unified Op/Status state model.
class AddExpenseModalBloc
    extends Bloc<AddExpenseModalEvent, AddExpenseModalState> {
  final ExpenseInteractor _expenseInteractor;

  AddExpenseModalBloc()
    : _expenseInteractor = getIt<ExpenseInteractor>(),
      super(AddExpenseModalState.initial()) {
    on<AddExpenseCategorySelected>(_onCategorySelected);
    on<AddExpenseCurrencySelected>(_onCurrencySelected);
    on<AddExpenseDateSelected>(_onDateSelected);
    on<AddExpenseResetRequested>(_onResetRequested);
    on<AddExpenseSubmitted>(_onSubmitted);
  }

  void _onCategorySelected(
    AddExpenseCategorySelected e,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(state.copyWith(selectedCategory: () => e.category));
  }

  void _onCurrencySelected(
    AddExpenseCurrencySelected e,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(state.copyWith(selectedCurrency: () => e.currency));
  }

  void _onDateSelected(
    AddExpenseDateSelected e,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(state.copyWith(selectedDate: e.date));
  }

  void _onResetRequested(
    AddExpenseResetRequested e,
    Emitter<AddExpenseModalState> emit,
  ) {
    emit(AddExpenseModalState.initial());
  }

  Future<void> _onSubmitted(
    AddExpenseSubmitted e,
    Emitter<AddExpenseModalState> emit,
  ) async {
    // mark create as loading and clear previous error/id
    emit(
      state.copyWith(
        status: {...state.status, Op.create: ExpenseStatus.loading},
        errors: {...state.errors, Op.create: null},
        createdExpenseId: () => null,
      ),
    );

    final result = await _expenseInteractor.createExpense(
      amount: e.amount,
      description: e.description,
      categoryId: e.categoryId,
      date: e.date,
      currencyId: e.currencyId,
      notes: e.notes,
      isRecurring: false,
      recurringType: null,
    );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: {...state.status, Op.create: ExpenseStatus.failure},
          errors: {...state.errors, Op.create: failure},
        ),
      ),
      (expenseId) => emit(
        state.copyWith(
          status: {...state.status, Op.create: ExpenseStatus.success},
          createdExpenseId: () => expenseId,
        ),
      ),
    );
  }
}
