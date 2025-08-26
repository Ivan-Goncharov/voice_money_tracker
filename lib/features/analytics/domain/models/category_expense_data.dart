import '../../../../core/data/database/database.dart';

/// Domain model representing expense distribution for a category
class CategoryExpenseData {
  const CategoryExpenseData({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.color,
    required this.percentage,
  });

  final int categoryId;
  final String categoryName;
  final double amount;
  final String color;
  final double percentage;
}

/// Aggregated analytics data emitted by the interactor stream
class AnalyticsBundle {
  const AnalyticsBundle({
    required this.balance,
    required this.monthlyExpenses,
    required this.monthlyIncome,
    required this.categoryBreakdown,
    required this.recentTransactions,
  });

  final double balance;
  final double monthlyExpenses;
  final double monthlyIncome;
  final List<CategoryExpenseData> categoryBreakdown;
  final List<ExpenseWithCategory> recentTransactions;
}
