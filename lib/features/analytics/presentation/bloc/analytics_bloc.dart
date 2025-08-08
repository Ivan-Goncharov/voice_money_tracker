import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interactors/analytics_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

/// BLoC for managing analytics operations
/// Handles loading balance, statistics, category breakdown, and recent transactions
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsInteractor _interactor;

  AnalyticsBloc()
    : _interactor = getIt<AnalyticsInteractor>(),
      super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<LoadAnalyticsForDateRange>(_onLoadAnalyticsForDateRange);
    on<RefreshAnalytics>(_onRefreshAnalytics);
    on<LoadCategoryBreakdown>(_onLoadCategoryBreakdown);
    on<LoadRecentTransactions>(_onLoadRecentTransactions);
  }

  /// Handle loading analytics data for current period
  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    try {
      // Get current month date range
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0);

      await _loadAnalyticsData(emit, startOfMonth, endOfMonth);
    } catch (error) {
      emit(AnalyticsError(message: error.toString()));
    }
  }

  /// Handle loading analytics data for specific date range
  Future<void> _onLoadAnalyticsForDateRange(
    LoadAnalyticsForDateRange event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading());

    try {
      await _loadAnalyticsData(emit, event.startDate, event.endDate);
    } catch (error) {
      emit(AnalyticsError(message: error.toString()));
    }
  }

  /// Handle refreshing analytics data
  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Reload current analytics
    add(const LoadAnalytics());
  }

  /// Handle loading category breakdown
  Future<void> _onLoadCategoryBreakdown(
    LoadCategoryBreakdown event,
    Emitter<AnalyticsState> emit,
  ) async {
    // This will be handled as part of LoadAnalytics
    add(const LoadAnalytics());
  }

  /// Handle loading recent transactions
  Future<void> _onLoadRecentTransactions(
    LoadRecentTransactions event,
    Emitter<AnalyticsState> emit,
  ) async {
    // This will be handled as part of LoadAnalytics
    add(const LoadAnalytics());
  }

  /// Common method to load all analytics data
  Future<void> _loadAnalyticsData(
    Emitter<AnalyticsState> emit,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Load balance
      final balanceResult = await _interactor.getCurrentBalance();

      // Load monthly expenses
      final expensesResult = await _interactor.getTotalExpensesForPeriod(
        startDate,
        endDate,
      );

      // Load monthly income (for now, we'll calculate as balance + expenses)
      // TODO: Implement proper income tracking
      final incomeResult = await _interactor.getEstimatedIncomeForPeriod(
        startDate,
        endDate,
      );

      // Load category breakdown
      final categoryBreakdownResult = await _interactor.getCategoryBreakdown(
        startDate,
        endDate,
      );

      // Load recent transactions
      final recentTransactionsResult = await _interactor.getRecentTransactions(
        5,
      );

      // Check each result individually
      if (balanceResult.isLeft()) {
        final failure = balanceResult.fold((l) => l, (r) => null);
        emit(
          AnalyticsError(message: failure?.message ?? 'Failed to load balance'),
        );
        return;
      }

      if (expensesResult.isLeft()) {
        final failure = expensesResult.fold((l) => l, (r) => null);
        emit(
          AnalyticsError(
            message: failure?.message ?? 'Failed to load expenses',
          ),
        );
        return;
      }

      if (incomeResult.isLeft()) {
        final failure = incomeResult.fold((l) => l, (r) => null);
        emit(
          AnalyticsError(message: failure?.message ?? 'Failed to load income'),
        );
        return;
      }

      if (categoryBreakdownResult.isLeft()) {
        final failure = categoryBreakdownResult.fold((l) => l, (r) => null);
        emit(
          AnalyticsError(
            message: failure?.message ?? 'Failed to load category breakdown',
          ),
        );
        return;
      }

      if (recentTransactionsResult.isLeft()) {
        final failure = recentTransactionsResult.fold((l) => l, (r) => null);
        emit(
          AnalyticsError(
            message: failure?.message ?? 'Failed to load recent transactions',
          ),
        );
        return;
      }

      // Extract successful results
      final balance = balanceResult.fold((l) => 0.0, (r) => r);
      final monthlyExpenses = expensesResult.fold((l) => 0.0, (r) => r);
      final monthlyIncome = incomeResult.fold((l) => 0.0, (r) => r);
      final categoryBreakdown = categoryBreakdownResult.fold(
        (l) => <CategoryExpenseData>[],
        (r) => r,
      );
      final recentTransactions = recentTransactionsResult.fold(
        (l) => <ExpenseWithCategory>[],
        (r) => r,
      );

      emit(
        AnalyticsLoaded(
          balance: balance,
          monthlyExpenses: monthlyExpenses,
          monthlyIncome: monthlyIncome,
          categoryBreakdown: categoryBreakdown,
          recentTransactions: recentTransactions,
        ),
      );
    } catch (error) {
      emit(AnalyticsError(message: error.toString()));
    }
  }
}
