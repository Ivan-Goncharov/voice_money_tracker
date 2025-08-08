part of 'analytics_bloc.dart';

/// Events for AnalyticsBloc
/// Represents all possible events for analytics operations
sealed class AnalyticsEvent {
  const AnalyticsEvent();
}

/// Load analytics data for the current period
final class LoadAnalytics extends AnalyticsEvent {
  const LoadAnalytics();
}

/// Load analytics data for a specific date range
final class LoadAnalyticsForDateRange extends AnalyticsEvent {
  const LoadAnalyticsForDateRange({
    required this.startDate,
    required this.endDate,
  });

  final DateTime startDate;
  final DateTime endDate;
}

/// Refresh analytics data
final class RefreshAnalytics extends AnalyticsEvent {
  const RefreshAnalytics();
}

/// Load category breakdown data
final class LoadCategoryBreakdown extends AnalyticsEvent {
  const LoadCategoryBreakdown();
}

/// Load recent transactions
final class LoadRecentTransactions extends AnalyticsEvent {
  const LoadRecentTransactions({this.limit = 5});

  final int limit;
}
