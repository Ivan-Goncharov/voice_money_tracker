import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../expense/domain/repository.dart';
import '../../../category/domain/repository.dart';
import '../models/category_expense_data.dart';

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

  /// Build category breakdown for a list of expenses and categories
  Either<Failure, List<CategoryExpenseData>> buildCategoryBreakdown(
    List<ExpenseEntity> expenses,
    List<CategoryEntity> categories,
  ) {
    try {
      final categoryTotals = <int, double>{};
      double totalExpenses = 0;

      for (final expense in expenses) {
        categoryTotals[expense.categoryId] =
            (categoryTotals[expense.categoryId] ?? 0) + expense.amount;
        totalExpenses += expense.amount;
      }

      final breakdown = <CategoryExpenseData>[];
      for (final category in categories) {
        final amount = categoryTotals[category.id] ?? 0;
        if (amount > 0) {
          final percentage = totalExpenses > 0 ? (amount / totalExpenses) * 100 : 0.0;
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

      breakdown.sort((a, b) => b.amount.compareTo(a.amount));
      return Right(breakdown);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to build category breakdown: ${e.toString()}'),
      );
    }
  }

  /// Build recent transactions from raw expenses + categories
  Either<Failure, List<ExpenseWithCategory>> buildRecentTransactions(
    List<ExpenseEntity> allExpenses,
    List<CategoryEntity> categories, {
    int limit = 5,
  }) {
    try {
      final byId = {for (final c in categories) c.id: c};
      final sorted = List<ExpenseEntity>.from(allExpenses)
        ..sort((a, b) => b.date.compareTo(a.date));
      final recent = sorted.take(limit).map((e) {
        return ExpenseWithCategory(expense: e, category: byId[e.categoryId]);
      }).toList();
      return Right(recent);
    } catch (e) {
      return Left(
        DatabaseFailure('Failed to build recent transactions: ${e.toString()}'),
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

  /// Expose a stream of analytics bundle for a given date range.
  /// This combines expense and category streams and computes derived metrics.
  Stream<Either<Failure, AnalyticsBundle>> watchAnalyticsForRange(
    DateTime startDate,
    DateTime endDate, {
    int recentLimit = 5,
  }) {
    // Source streams
    final expensesInRange$ =
        _expenseRepository.watchExpensesByDateRange(startDate, endDate);
    // Use a wide range to approximate "all-time" for balance and recents
    final allExpenses$ = _expenseRepository.watchExpensesByDateRange(
      DateTime(2020, 1, 1),
      DateTime.now(),
    );
    final categories$ = _categoryRepository.watchActiveCategories();

    // Latest caches
    Either<Failure, List<ExpenseEntity>>? latestInRange;
    Either<Failure, List<ExpenseEntity>>? latestAll;
    Either<Failure, List<CategoryEntity>>? latestCats;

    late final StreamController<Either<Failure, AnalyticsBundle>> controller;
    StreamSubscription? a;
    StreamSubscription? b;
    StreamSubscription? c;

    void recompute() {
      if (latestInRange == null || latestAll == null || latestCats == null) {
        return;
      }
      // If any is a failure, emit the first failure
      final failure = latestInRange!.fold<Failure?>(
        (l) => l,
        (_) => latestAll!.fold<Failure?>(
          (l) => l,
          (_) => latestCats!.fold<Failure?>(
            (l) => l,
            (_) => null,
          ),
        ),
      );
      if (failure != null) {
        controller.add(Left(failure));
        return;
      }

      final expensesInRange = latestInRange!.fold((_) => <ExpenseEntity>[], (r) => r);
      final allExpenses = latestAll!.fold((_) => <ExpenseEntity>[], (r) => r);
      final categories = latestCats!.fold((_) => <CategoryEntity>[], (r) => r);

      final monthlyExpenses = expensesInRange.fold<double>(0.0, (sum, e) => sum + e.amount);
      final monthlyIncome = monthlyExpenses * 1.5; // demo income estimation

      final breakdownEither = buildCategoryBreakdown(expensesInRange, categories);
      final recentsEither = buildRecentTransactions(
        allExpenses,
        categories,
        limit: recentLimit,
      );

      if (breakdownEither.isLeft()) {
        controller.add(Left(breakdownEither.fold((l) => l, (_) => DatabaseFailure('unknown'))));
        return;
      }
      if (recentsEither.isLeft()) {
        controller.add(Left(recentsEither.fold((l) => l, (_) => DatabaseFailure('unknown'))));
        return;
      }

      // Current balance: starting 0 - sum(all expenses)
      final totalAll = allExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
      const startingBalance = 0.0;
      final balance = startingBalance - totalAll;

      controller.add(
        Right(
          AnalyticsBundle(
            balance: balance,
            monthlyExpenses: monthlyExpenses,
            monthlyIncome: monthlyIncome,
            categoryBreakdown: breakdownEither.fold((_) => const [], (r) => r),
            recentTransactions: recentsEither.fold((_) => const [], (r) => r),
          ),
        ),
      );
    }

    controller = StreamController<Either<Failure, AnalyticsBundle>>.broadcast(
      onListen: () {
        a = expensesInRange$.listen((event) {
          latestInRange = event;
          recompute();
        });
        b = allExpenses$.listen((event) {
          latestAll = event;
          recompute();
        });
        c = categories$.listen((event) {
          latestCats = event;
          recompute();
        });
      },
      onCancel: () async {
        await a?.cancel();
        await b?.cancel();
        await c?.cancel();
      },
    );

    return controller.stream;
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
