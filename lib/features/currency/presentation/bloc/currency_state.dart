part of 'currency_bloc.dart';

/// States for CurrencyBloc
/// Represents all possible states for currency operations
sealed class CurrencyState {
  const CurrencyState();
}

/// Initial state
final class CurrencyInitial extends CurrencyState {
  const CurrencyInitial();
}

/// Loading state
final class CurrencyLoading extends CurrencyState {
  const CurrencyLoading();
}

/// Currencies loaded successfully
final class CurrenciesLoaded extends CurrencyState {
  const CurrenciesLoaded({
    required this.currencies,
    this.defaultCurrency,
  });

  final List<CurrencyEntity> currencies;
  final CurrencyEntity? defaultCurrency;
}

/// Single currency loaded successfully
final class CurrencyLoaded extends CurrencyState {
  const CurrencyLoaded(this.currency);

  final CurrencyEntity? currency;
}

/// Default currency loaded successfully
final class DefaultCurrencyLoaded extends CurrencyState {
  const DefaultCurrencyLoaded(this.currency);

  final CurrencyEntity? currency;
}

/// Error state
final class CurrencyError extends CurrencyState {
  const CurrencyError({required this.message});

  final String message;
}
