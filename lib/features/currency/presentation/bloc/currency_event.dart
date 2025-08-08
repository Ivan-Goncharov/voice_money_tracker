part of 'currency_bloc.dart';

/// Events for CurrencyBloc
/// Represents all possible user actions and system events for currencies
sealed class CurrencyEvent {
  const CurrencyEvent();
}

/// Load all active currencies
final class LoadActiveCurrencies extends CurrencyEvent {
  const LoadActiveCurrencies();
}

/// Load default currency (RUB)
final class LoadDefaultCurrency extends CurrencyEvent {
  const LoadDefaultCurrency();
}

/// Get currency by ID
final class GetCurrencyById extends CurrencyEvent {
  const GetCurrencyById(this.id);

  final int id;
}

/// Get currency by code
final class GetCurrencyByCode extends CurrencyEvent {
  const GetCurrencyByCode(this.code);

  final String code;
}
