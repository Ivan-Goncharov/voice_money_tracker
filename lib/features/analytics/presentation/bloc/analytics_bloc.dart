import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';
import '../../domain/interactors/analytics_interactor.dart';
import '../../domain/models/category_expense_data.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../../../../core/error/failures.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

/// BLoC for managing analytics operations
/// Handles loading balance, statistics, category breakdown, and recent transactions
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final AnalyticsInteractor _interactor;
  StreamSubscription? _analyticsSub;
  DateTime? _currentStart;
  DateTime? _currentEnd;

  AnalyticsBloc()
    : _interactor = getIt<AnalyticsInteractor>(),
      super(const AnalyticsInitial()) {
    on<LoadAnalytics>(_onLoadAnalytics);
    on<LoadAnalyticsForDateRange>(_onLoadAnalyticsForDateRange);
    on<RefreshAnalytics>(_onRefreshAnalytics);
    on<_AnalyticsStreamUpdated>(_onStreamUpdated);
  }

  /// Handle loading analytics data for current period
  Future<void> _onLoadAnalytics(
    LoadAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Get current month date range
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    _subscribeToRange(emit, startOfMonth, endOfMonth);
  }

  /// Handle loading analytics data for specific date range
  Future<void> _onLoadAnalyticsForDateRange(
    LoadAnalyticsForDateRange event,
    Emitter<AnalyticsState> emit,
  ) async {
    _subscribeToRange(emit, event.startDate, event.endDate);
  }

  /// Handle refreshing analytics data
  Future<void> _onRefreshAnalytics(
    RefreshAnalytics event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Re-subscribe to current range if available
    if (_currentStart != null && _currentEnd != null) {
      _subscribeToRange(emit, _currentStart!, _currentEnd!);
    } else {
      add(const LoadAnalytics());
    }
  }

  void _subscribeToRange(
    Emitter<AnalyticsState> emit,
    DateTime startDate,
    DateTime endDate,
  ) {
    _currentStart = startDate;
    _currentEnd = endDate;

    emit(const AnalyticsLoading());
    _analyticsSub?.cancel();
    _analyticsSub = _interactor
        .watchAnalyticsForRange(startDate, endDate, recentLimit: 5)
        .listen((either) {
      add(_AnalyticsStreamUpdated(either));
    });
  }

  @override
  Future<void> close() async {
    await _analyticsSub?.cancel();
    return super.close();
  }

  Future<void> _onStreamUpdated(
    _AnalyticsStreamUpdated event,
    Emitter<AnalyticsState> emit,
  ) async {
    event.result.fold(
      (failure) => emit(AnalyticsError(message: failure.message)),
      (bundle) => emit(
        AnalyticsLoaded(
          balance: bundle.balance,
          monthlyExpenses: bundle.monthlyExpenses,
          monthlyIncome: bundle.monthlyIncome,
          categoryBreakdown: bundle.categoryBreakdown,
          recentTransactions: bundle.recentTransactions,
        ),
      ),
    );
  }
}
