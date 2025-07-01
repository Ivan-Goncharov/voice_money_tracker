import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../repository.dart';

/// Interactor for expense business logic
/// Handles the coordination between repository and presentation layer
class ExpenseInteractor {
  final ExpenseRepository _repository;

  ExpenseInteractor() : _repository = getIt<ExpenseRepository>();

  /// Get all expenses
  Future<Either<Failure, List<ExpenseEntity>>> getAllExpenses() async {
    return await _repository.getAllExpenses();
  }

  /// Get expenses within a specific date range
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getExpensesByDateRange(startDate, endDate);
  }

  /// Get expenses for a specific category
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByCategory(int categoryId) async {
    return await _repository.getExpensesByCategory(categoryId);
  }

  /// Get a specific expense by ID
  Future<Either<Failure, ExpenseEntity?>> getExpenseById(int id) async {
    return await _repository.getExpenseById(id);
  }

  /// Create a new expense
  Future<Either<Failure, int>> createExpense({
    required double amount,
    required String description,
    required int categoryId,
    required DateTime date,
    String? notes,
    bool isRecurring = false,
    String? recurringType,
  }) async {
    // Validate amount
    if (amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than 0'));
    }

    // Validate description
    if (description.trim().isEmpty) {
      return const Left(ValidationFailure('Description cannot be empty'));
    }

    final expense = ExpensesCompanion.insert(
      amount: amount,
      description: description.trim(),
      categoryId: categoryId,
      date: date,
      notes: Value(notes),
      isRecurring: Value(isRecurring),
      recurringType: Value(recurringType),
    );

    return await _repository.insertExpense(expense);
  }

  /// Update an existing expense
  Future<Either<Failure, bool>> updateExpense({
    required int id,
    double? amount,
    String? description,
    int? categoryId,
    DateTime? date,
    String? notes,
    bool? isRecurring,
    String? recurringType,
  }) async {
    // Validate amount if provided
    if (amount != null && amount <= 0) {
      return const Left(ValidationFailure('Amount must be greater than 0'));
    }

    // Validate description if provided
    if (description != null && description.trim().isEmpty) {
      return const Left(ValidationFailure('Description cannot be empty'));
    }

    final expense = ExpensesCompanion(
      amount: amount != null ? Value(amount) : const Value.absent(),
      description: description != null ? Value(description.trim()) : const Value.absent(),
      categoryId: categoryId != null ? Value(categoryId) : const Value.absent(),
      date: date != null ? Value(date) : const Value.absent(),
      notes: notes != null ? Value(notes) : const Value.absent(),
      isRecurring: isRecurring != null ? Value(isRecurring) : const Value.absent(),
      recurringType: recurringType != null ? Value(recurringType) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await _repository.updateExpense(id, expense);
  }

  /// Delete an expense permanently
  Future<Either<Failure, int>> deleteExpense(int id) async {
    return await _repository.deleteExpense(id);
  }

  /// Get total amount of expenses for a specific category
  Future<Either<Failure, double>> getTotalExpensesByCategory(int categoryId) async {
    return await _repository.getTotalExpensesByCategory(categoryId);
  }

  /// Get total amount of expenses within a date range
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _repository.getTotalExpensesByDateRange(startDate, endDate);
  }

  /// Get expenses with their associated category information
  Future<Either<Failure, List<ExpenseWithCategory>>> getExpensesWithCategory() async {
    return await _repository.getExpensesWithCategory();
  }

  /// Watch expenses within a date range for real-time updates
  Stream<Either<Failure, List<ExpenseEntity>>> watchExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return _repository.watchExpensesByDateRange(startDate, endDate);
  }
}
