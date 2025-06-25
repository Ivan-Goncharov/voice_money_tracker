import 'app_database.dart';

/// Interface for Expenses Data Access Object
/// This abstraction allows repositories to work with expenses data
/// without directly depending on Drift implementation details
abstract interface class ExpensesDaoInterface {
  /// Get all expenses from the database
  Future<List<ExpenseEntity>> getAllExpenses();

  /// Get expenses within a specific date range
  Future<List<ExpenseEntity>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get expenses for a specific category
  Future<List<ExpenseEntity>> getExpensesByCategory(int categoryId);

  /// Get a specific expense by ID
  Future<ExpenseEntity?> getExpenseById(int id);

  /// Insert a new expense
  Future<int> insertExpense(ExpensesCompanion expense);

  /// Update an existing expense
  Future<bool> updateExpense(int id, ExpensesCompanion expense);

  /// Delete an expense permanently
  Future<int> deleteExpense(int id);

  /// Get total amount of expenses for a specific category
  Future<double> getTotalExpensesByCategory(int categoryId);

  /// Get total amount of expenses within a date range
  Future<double> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get expenses with their associated category information
  Future<List<ExpenseWithCategory>> getExpensesWithCategory();

  /// Watch expenses within a date range for real-time updates
  Stream<List<ExpenseEntity>> watchExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
