part of 'expense_bloc.dart';

/// States for ExpenseBloc
/// Represents all possible states during expense operations
sealed class ExpenseState {
  const ExpenseState();
}

/// Initial state when the bloc is created
final class ExpenseInitial extends ExpenseState {
  const ExpenseInitial();
}

/// Loading state while performing expense operations
final class ExpenseLoading extends ExpenseState {
  const ExpenseLoading();
}

/// State with loaded expenses
final class ExpenseLoaded extends ExpenseState {
  const ExpenseLoaded({required this.expenses, this.isWatching = false});

  final List<ExpenseEntity> expenses;
  final bool isWatching;
}

/// State with loaded expenses including category information
final class ExpenseLoadedWithCategory extends ExpenseState {
  const ExpenseLoadedWithCategory({required this.expensesWithCategory});

  final List<ExpenseWithCategory> expensesWithCategory;
}

/// State indicating successful expense creation
final class ExpenseCreated extends ExpenseState {
  const ExpenseCreated({required this.expenseId, required this.expenses});

  final int expenseId;
  final List<ExpenseEntity> expenses;
}

/// State indicating successful expense update
final class ExpenseUpdated extends ExpenseState {
  const ExpenseUpdated({required this.expenses});

  final List<ExpenseEntity> expenses;
}

/// State indicating successful expense deletion
final class ExpenseDeleted extends ExpenseState {
  const ExpenseDeleted({required this.expenses});

  final List<ExpenseEntity> expenses;
}

/// State with total amount information
final class ExpenseTotalLoaded extends ExpenseState {
  const ExpenseTotalLoaded({required this.total, this.expenses});

  final double total;
  final List<ExpenseEntity>? expenses;
}

/// Error state when something goes wrong
final class ExpenseError extends ExpenseState {
  const ExpenseError({required this.message, this.expenses});

  final String message;
  final List<ExpenseEntity>? expenses;
}
