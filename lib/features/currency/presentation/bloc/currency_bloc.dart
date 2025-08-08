import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interactors/currency_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';

part 'currency_event.dart';
part 'currency_state.dart';

/// BLoC for managing currency operations
/// Handles loading currencies and currency selection
class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyInteractor _interactor;

  CurrencyBloc()
      : _interactor = getIt<CurrencyInteractor>(),
        super(const CurrencyInitial()) {
    on<LoadActiveCurrencies>(_onLoadActiveCurrencies);
    on<LoadDefaultCurrency>(_onLoadDefaultCurrency);
    on<GetCurrencyById>(_onGetCurrencyById);
    on<GetCurrencyByCode>(_onGetCurrencyByCode);
  }

  /// Handle loading active currencies
  Future<void> _onLoadActiveCurrencies(
    LoadActiveCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    final result = await _interactor.getActiveCurrencies();

    result.fold(
      (failure) => emit(CurrencyError(message: failure.message)),
      (currencies) => emit(CurrenciesLoaded(currencies: currencies)),
    );
  }

  /// Handle loading default currency
  Future<void> _onLoadDefaultCurrency(
    LoadDefaultCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    final result = await _interactor.getDefaultCurrency();

    result.fold(
      (failure) => emit(CurrencyError(message: failure.message)),
      (currency) => emit(DefaultCurrencyLoaded(currency)),
    );
  }

  /// Handle getting currency by ID
  Future<void> _onGetCurrencyById(
    GetCurrencyById event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    final result = await _interactor.getCurrencyById(event.id);

    result.fold(
      (failure) => emit(CurrencyError(message: failure.message)),
      (currency) => emit(CurrencyLoaded(currency)),
    );
  }

  /// Handle getting currency by code
  Future<void> _onGetCurrencyByCode(
    GetCurrencyByCode event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(const CurrencyLoading());

    final result = await _interactor.getCurrencyByCode(event.code);

    result.fold(
      (failure) => emit(CurrencyError(message: failure.message)),
      (currency) => emit(CurrencyLoaded(currency)),
    );
  }
}
