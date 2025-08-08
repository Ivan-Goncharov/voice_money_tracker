part of 'analytics_bloc.dart';

/// States for AnalyticsBloc
/// Represents all possible states during analytics operations
sealed class AnalyticsState {
  const AnalyticsState();
}

/// Initial state when the bloc is created
final class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// Loading state while performing analytics operations
final class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

/// State with loaded analytics data
final class AnalyticsLoaded extends AnalyticsState {
  const AnalyticsLoaded({
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

/// Error state when analytics operations fail
final class AnalyticsError extends AnalyticsState {
  const AnalyticsError({required this.message});

  final String message;
}

/// Data class for category expense breakdown
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
