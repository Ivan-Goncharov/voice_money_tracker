import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../expense/domain/repository.dart';
import '../../../category/domain/repository.dart';
import '../../presentation/bloc/analytics_bloc.dart';

/// Interactor for analytics business logic
/// Handles calculations for balance, statistics, and data preparation for charts
class AnalyticsInteractor {
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;

  AnalyticsInteractor()
    : _expenseRepository = getIt<ExpenseRepository>(),
      _categoryRepository = getIt<CategoryRepository>();

  /// Get current balance (for now, we'll calculate as negative total expenses)
  /// TODO: Implement proper balance tracking with income
  Future<Either<Failure, double>> getCurrentBalance() async {
    try {
      final totalExpensesResult = await _expenseRepository
          .getTotalExpensesByDateRange(
            DateTime(2020, 1, 1), // Start from a very early date
            DateTime.now(),
          );

      return totalExpensesResult.fold((failure) => Left(failure), (
        totalExpenses,
      ) {
        // Starting balance is 0, so current balance is negative total expenses
        const startingBalance = 0.0;
        final currentBalance = startingBalance - totalExpenses;
        return Right(currentBalance);
      });
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to calculate balance: ${e.toString()}'),
      );
    }
  }

  /// Get total expenses for a specific period
  Future<Either<Failure, double>> getTotalExpensesForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return await _expenseRepository.getTotalExpensesByDateRange(
      startDate,
      endDate,
    );
  }

  /// Get estimated income for a period (for demo purposes)
  /// TODO: Implement proper income tracking
  Future<Either<Failure, double>> getEstimatedIncomeForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final expensesResult = await getTotalExpensesForPeriod(
        startDate,
        endDate,
      );

      return expensesResult.fold((failure) => Left(failure), (expenses) {
        // For demo: assume income is 1.5x expenses to maintain positive balance
        final estimatedIncome = expenses * 1.5;
        return Right(estimatedIncome);
      });
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to calculate income: ${e.toString()}'),
      );
    }
  }

  /// Get category breakdown for expenses in a period
  Future<Either<Failure, List<CategoryExpenseData>>> getCategoryBreakdown(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Get all expenses with categories for the period
      final expensesResult = await _expenseRepository.getExpensesByDateRange(
        startDate,
        endDate,
      );
      final categoriesResult = await _categoryRepository.getActiveCategories();

      return expensesResult.fold(
        (failure) => Left(failure),
        (expenses) =>
            categoriesResult.fold((failure) => Left(failure), (categories) {
              // Group expenses by category
              final categoryTotals = <int, double>{};
              double totalExpenses = 0;

              for (final expense in expenses) {
                categoryTotals[expense.categoryId] =
                    (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
                totalExpenses += expense.amount;
              }

              // Create category breakdown data
              final breakdown = <CategoryExpenseData>[];
              for (final category in categories) {
                final amount = categoryTotals[category.id] ?? 0;
                if (amount > 0) {
                  final percentage =
                      totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0.0;
                  breakdown.add(
                    CategoryExpenseData(
                      categoryId: category.id,
                      categoryName: category.name,
                      amount: amount,
                      color: category.color,
                      percentage: percentage,
                    ),
                  );
                }
              }

              // Sort by amount descending
              breakdown.sort((a, b) => b.amount.compareTo(a.amount));

              return Right(breakdown);
            }),
      );
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get category breakdown: ${e.toString()}'),
      );
    }
  }

  /// Get recent transactions with category information
  Future<Either<Failure, List<ExpenseWithCategory>>> getRecentTransactions(
    int limit,
  ) async {
    try {
      final expensesResult = await _expenseRepository.getExpensesWithCategory();

      return expensesResult.fold((failure) => Left(failure), (expenses) {
        // Sort by date descending and take the limit
        expenses.sort((a, b) => b.expense.date.compareTo(a.expense.date));
        final recentExpenses = expenses.take(limit).toList();
        return Right(recentExpenses);
      });
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get recent transactions: ${e.toString()}'),
      );
    }
  }

  /// Get monthly statistics for a specific month
  Future<Either<Failure, MonthlyStats>> getMonthlyStats(
    int year,
    int month,
  ) async {
    try {
      final startDate = DateTime(year, month, 1);
      final endDate = DateTime(year, month + 1, 0);

      final expensesResult = await getTotalExpensesForPeriod(
        startDate,
        endDate,
      );
      final incomeResult = await getEstimatedIncomeForPeriod(
        startDate,
        endDate,
      );

      return expensesResult.fold(
        (failure) => Left(failure),
        (expenses) => incomeResult.fold(
          (failure) => Left(failure),
          (income) => Right(
            MonthlyStats(
              year: year,
              month: month,
              totalExpenses: expenses,
              totalIncome: income,
              netAmount: income - expenses,
            ),
          ),
        ),
      );
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to get monthly stats: ${e.toString()}'),
      );
    }
  }
}

/// Data class for monthly statistics
class MonthlyStats {
  const MonthlyStats({
    required this.year,
    required this.month,
    required this.totalExpenses,
    required this.totalIncome,
    required this.netAmount,
  });

  final int year;
  final int month;
  final double totalExpenses;
  final double totalIncome;
  final double netAmount;
}
