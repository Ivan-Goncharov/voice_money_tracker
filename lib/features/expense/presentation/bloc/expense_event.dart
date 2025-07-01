part of 'expense_bloc.dart';

/// Events for ExpenseBloc
/// Represents all possible user actions and system events for expenses
sealed class ExpenseEvent {
  const ExpenseEvent();
}

/// Load all expenses
final class LoadAllExpenses extends ExpenseEvent {
  const LoadAllExpenses();
}

/// Load expenses within a specific date range
final class LoadExpensesByDateRange extends ExpenseEvent {
  const LoadExpensesByDateRange({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
}

/// Load expenses for a specific category
final class LoadExpensesByCategory extends ExpenseEvent {
  const LoadExpensesByCategory(this.categoryId);

  final int categoryId;
}

/// Create a new expense
final class CreateExpense extends ExpenseEvent {
  const CreateExpense({
    required this.amount,
    required this.description,
    required this.categoryId,
    required this.date,
    this.notes,
    this.isRecurring = false,
    this.recurringType,
  });

  final double amount;
  final String description;
  final int categoryId;
  final DateTime date;
  final String? notes;
  final bool isRecurring;
  final String? recurringType;
}

/// Update an existing expense
final class UpdateExpense extends ExpenseEvent {
  const UpdateExpense({
    required this.id,
    this.amount,
    this.description,
    this.categoryId,
    this.date,
    this.notes,
    this.isRecurring,
    this.recurringType,
  });

  final int id;
  final double? amount;
  final String? description;
  final int? categoryId;
  final DateTime? date;
  final String? notes;
  final bool? isRecurring;
  final String? recurringType;
}

/// Delete an expense permanently
final class DeleteExpense extends ExpenseEvent {
  const DeleteExpense(this.id);

  final int id;
}

/// Load expenses with category information
final class LoadExpensesWithCategory extends ExpenseEvent {
  const LoadExpensesWithCategory();
}

/// Get total expenses for a category
final class GetTotalByCategory extends ExpenseEvent {
  const GetTotalByCategory(this.categoryId);

  final int categoryId;
}

/// Get total expenses for a date range
final class GetTotalByDateRange extends ExpenseEvent {
  const GetTotalByDateRange({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;
}

/// Start watching expenses for real-time updates
final class StartWatchingExpenses extends ExpenseEvent {
  const StartWatchingExpenses({required this.startDate, required this.endDate});

  final DateTime startDate;
  final DateTime endDate;
}

/// Stop watching expenses
final class StopWatchingExpenses extends ExpenseEvent {
  const StopWatchingExpenses();
}
