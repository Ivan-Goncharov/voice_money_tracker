import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/data/database/database.dart';

/// Repository interface for managing expenses
/// Provides abstraction over data layer for expense operations
abstract interface class ExpenseRepository {
  /// Get all expenses from the database
  Future<Either<Failure, List<ExpenseEntity>>> getAllExpenses();

  /// Get expenses within a specific date range
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get expenses for a specific category
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByCategory(int categoryId);

  /// Get a specific expense by ID
  Future<Either<Failure, ExpenseEntity?>> getExpenseById(int id);

  /// Insert a new expense
  Future<Either<Failure, int>> insertExpense(ExpensesCompanion expense);

  /// Update an existing expense
  Future<Either<Failure, bool>> updateExpense(int id, ExpensesCompanion expense);

  /// Delete an expense permanently
  Future<Either<Failure, int>> deleteExpense(int id);

  /// Get total amount of expenses for a specific category
  Future<Either<Failure, double>> getTotalExpensesByCategory(int categoryId);

  /// Get total amount of expenses within a date range
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Get expenses with their associated category information
  Future<Either<Failure, List<ExpenseWithCategory>>> getExpensesWithCategory();

  /// Watch expenses within a date range for real-time updates
  Stream<Either<Failure, List<ExpenseEntity>>> watchExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );
}
