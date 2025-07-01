import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/service_locator/service_locator.dart';
import '../../../core/data/database/database.dart';
import '../domain/repository.dart';

/// Implementation of ExpenseRepository using Drift database
/// Handles all expense-related database operations
class ExpenseRepositoryImpl implements ExpenseRepository {
  final AppDatabase _database;

  ExpenseRepositoryImpl() : _database = getIt<AppDatabase>();

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getAllExpenses() async {
    try {
      final expenses = await _database.expensesDao.getAllExpenses();
      return Right(expenses);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all expenses: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expenses = await _database.expensesDao.getExpensesByDateRange(startDate, endDate);
      return Right(expenses);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get expenses by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getExpensesByCategory(int categoryId) async {
    try {
      final expenses = await _database.expensesDao.getExpensesByCategory(categoryId);
      return Right(expenses);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get expenses by category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity?>> getExpenseById(int id) async {
    try {
      final expense = await _database.expensesDao.getExpenseById(id);
      return Right(expense);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get expense by ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> insertExpense(ExpensesCompanion expense) async {
    try {
      final id = await _database.expensesDao.insertExpense(expense);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to insert expense: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateExpense(int id, ExpensesCompanion expense) async {
    try {
      final success = await _database.expensesDao.updateExpense(id, expense);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update expense: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteExpense(int id) async {
    try {
      final deletedCount = await _database.expensesDao.deleteExpense(id);
      return Right(deletedCount);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete expense: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpensesByCategory(int categoryId) async {
    try {
      final total = await _database.expensesDao.getTotalExpensesByCategory(categoryId);
      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get total expenses by category: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, double>> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final total = await _database.expensesDao.getTotalExpensesByDateRange(startDate, endDate);
      return Right(total);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get total expenses by date range: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<ExpenseWithCategory>>> getExpensesWithCategory() async {
    try {
      final expenses = await _database.expensesDao.getExpensesWithCategory();
      return Right(expenses);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get expenses with category: ${e.toString()}'));
    }
  }

  @override
  Stream<Either<Failure, List<ExpenseEntity>>> watchExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    try {
      return _database.expensesDao.watchExpensesByDateRange(startDate, endDate).map(
        (expenses) => Right<Failure, List<ExpenseEntity>>(expenses),
      );
    } catch (e) {
      return Stream.value(
        Left(DatabaseFailure('Failed to watch expenses by date range: ${e.toString()}')),
      );
    }
  }
}
