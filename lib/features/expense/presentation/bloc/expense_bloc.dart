import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/interactors/expense_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../../core/error/failures.dart';

part 'expense_event.dart';
part 'expense_state.dart';

/// BLoC for managing expense operations
/// Handles loading, creating, updating, and deleting expenses
class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpenseInteractor _interactor;
  StreamSubscription<Either<Failure, List<ExpenseEntity>>>?
  _expensesSubscription;

  ExpenseBloc()
    : _interactor = getIt<ExpenseInteractor>(),
      super(const ExpenseInitial()) {
    on<LoadAllExpenses>((event, emit) => _onLoadAllExpenses(emit));
    on<LoadExpensesByDateRange>(
      (event, emit) =>
          _onLoadExpensesByDateRange(emit, event.startDate, event.endDate),
    );
    on<LoadExpensesByCategory>(
      (event, emit) => _onLoadExpensesByCategory(emit, event.categoryId),
    );
    on<CreateExpense>(
      (event, emit) => _onCreateExpense(
        emit,
        event.amount,
        event.description,
        event.categoryId,
        event.date,
        event.currencyId,
        event.notes,
        event.isRecurring,
        event.recurringType,
      ),
    );
    on<UpdateExpense>(
      (event, emit) => _onUpdateExpense(
        emit,
        event.id,
        event.amount,
        event.description,
        event.categoryId,
        event.date,
        event.currencyId,
        event.notes,
        event.isRecurring,
        event.recurringType,
      ),
    );
    on<DeleteExpense>((event, emit) => _onDeleteExpense(emit, event.id));
    on<LoadExpensesWithCategory>(
      (event, emit) => _onLoadExpensesWithCategory(emit),
    );
    on<GetTotalByCategory>(
      (event, emit) => _onGetTotalByCategory(emit, event.categoryId),
    );
    on<GetTotalByDateRange>(
      (event, emit) =>
          _onGetTotalByDateRange(emit, event.startDate, event.endDate),
    );
    on<StartWatchingExpenses>(
      (event, emit) =>
          _onStartWatchingExpenses(emit, event.startDate, event.endDate),
    );
    on<StopWatchingExpenses>((event, emit) => _onStopWatchingExpenses(emit));
  }

  @override
  Future<void> close() {
    _expensesSubscription?.cancel();
    return super.close();
  }

  /// Handle loading all expenses
  Future<void> _onLoadAllExpenses(Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());

    final result = await _interactor.getAllExpenses();

    result.fold(
      (failure) => emit(ExpenseError(message: failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  /// Handle loading expenses by date range
  Future<void> _onLoadExpensesByDateRange(
    Emitter<ExpenseState> emit,
    DateTime startDate,
    DateTime endDate,
  ) async {
    emit(const ExpenseLoading());

    final result = await _interactor.getExpensesByDateRange(startDate, endDate);

    result.fold(
      (failure) => emit(ExpenseError(message: failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  /// Handle loading expenses by category
  Future<void> _onLoadExpensesByCategory(
    Emitter<ExpenseState> emit,
    int categoryId,
  ) async {
    emit(const ExpenseLoading());

    final result = await _interactor.getExpensesByCategory(categoryId);

    result.fold(
      (failure) => emit(ExpenseError(message: failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses: expenses)),
    );
  }

  /// Handle creating a new expense
  Future<void> _onCreateExpense(
    Emitter<ExpenseState> emit,
    double amount,
    String? description,
    int categoryId,
    DateTime date,
    int? currencyId,
    String? notes,
    bool isRecurring,
    String? recurringType,
  ) async {
    print(
      'DEBUG: ExpenseBloc._onCreateExpense called with amount: $amount, categoryId: $categoryId',
    );
    emit(const ExpenseLoading());

    final result = await _interactor.createExpense(
      amount: amount,
      description: description,
      categoryId: categoryId,
      date: date,
      currencyId: currencyId,
      notes: notes,
      isRecurring: isRecurring,
      recurringType: recurringType,
    );

    await result.fold(
      (failure) async {
        print('DEBUG: ExpenseBloc._onCreateExpense failed: ${failure.message}');
        emit(ExpenseError(message: failure.message));
      },
      (expenseId) async {
        print(
          'DEBUG: ExpenseBloc._onCreateExpense success, expenseId: $expenseId',
        );
        // Reload expenses after creation
        final expensesResult = await _interactor.getAllExpenses();
        expensesResult.fold(
          (failure) => emit(ExpenseError(message: failure.message)),
          (expenses) =>
              emit(ExpenseCreated(expenseId: expenseId, expenses: expenses)),
        );
      },
    );
  }

  /// Handle updating an expense
  Future<void> _onUpdateExpense(
    Emitter<ExpenseState> emit,
    int id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? date,
    int? currencyId,
    String? notes,
    bool? isRecurring,
    String? recurringType,
  ) async {
    emit(const ExpenseLoading());

    final result = await _interactor.updateExpense(
      id: id,
      amount: amount,
      description: description,
      categoryId: categoryId,
      date: date,
      currencyId: currencyId,
      notes: notes,
      isRecurring: isRecurring,
      recurringType: recurringType,
    );

    await result.fold(
      (failure) async => emit(ExpenseError(message: failure.message)),
      (success) async {
        if (success) {
          // Reload expenses after update
          final expensesResult = await _interactor.getAllExpenses();
          expensesResult.fold(
            (failure) => emit(ExpenseError(message: failure.message)),
            (expenses) => emit(ExpenseUpdated(expenses: expenses)),
          );
        } else {
          emit(const ExpenseError(message: 'Failed to update expense'));
        }
      },
    );
  }

  /// Handle deleting an expense
  Future<void> _onDeleteExpense(Emitter<ExpenseState> emit, int id) async {
    emit(const ExpenseLoading());

    final result = await _interactor.deleteExpense(id);

    await result.fold(
      (failure) async => emit(ExpenseError(message: failure.message)),
      (deletedCount) async {
        if (deletedCount > 0) {
          // Reload expenses after deletion
          final expensesResult = await _interactor.getAllExpenses();
          expensesResult.fold(
            (failure) => emit(ExpenseError(message: failure.message)),
            (expenses) => emit(ExpenseDeleted(expenses: expenses)),
          );
        } else {
          emit(const ExpenseError(message: 'Failed to delete expense'));
        }
      },
    );
  }

  /// Handle loading expenses with category information
  Future<void> _onLoadExpensesWithCategory(Emitter<ExpenseState> emit) async {
    emit(const ExpenseLoading());

    final result = await _interactor.getExpensesWithCategory();

    result.fold(
      (failure) => emit(ExpenseError(message: failure.message)),
      (expensesWithCategory) => emit(
        ExpenseLoadedWithCategory(expensesWithCategory: expensesWithCategory),
      ),
    );
  }

  /// Handle getting total by category
  Future<void> _onGetTotalByCategory(
    Emitter<ExpenseState> emit,
    int categoryId,
  ) async {
    final result = await _interactor.getTotalExpensesByCategory(categoryId);

    result.fold(
      (failure) => emit(ExpenseError(message: failure.message)),
      (total) => emit(ExpenseTotalLoaded(total: total)),
    );
  }

  /// Handle getting total by date range
  Future<void> _onGetTotalByDateRange(
    Emitter<ExpenseState> emit,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final result = await _interactor.getTotalExpensesByDateRange(
      startDate,
      endDate,
    );

    result.fold(
      (failure) => emit(ExpenseError(message: failure.message)),
      (total) => emit(ExpenseTotalLoaded(total: total)),
    );
  }

  /// Handle starting to watch expenses for real-time updates
  Future<void> _onStartWatchingExpenses(
    Emitter<ExpenseState> emit,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await _expensesSubscription?.cancel();

    _expensesSubscription = _interactor
        .watchExpensesByDateRange(startDate, endDate)
        .listen((result) {
          result.fold(
            (failure) => emit(ExpenseError(message: failure.message)),
            (expenses) =>
                emit(ExpenseLoaded(expenses: expenses, isWatching: true)),
          );
        });
  }

  /// Handle stopping watching expenses
  Future<void> _onStopWatchingExpenses(Emitter<ExpenseState> emit) async {
    await _expensesSubscription?.cancel();
    _expensesSubscription = null;

    // Keep current expenses but mark as not watching
    final currentState = state;
    if (currentState is ExpenseLoaded) {
      emit(ExpenseLoaded(expenses: currentState.expenses, isWatching: false));
    }
  }
}
