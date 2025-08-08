import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';
import '../repository.dart';

/// Interactor for currency business logic
/// Handles currency operations and validation
class CurrencyInteractor {
  final CurrencyRepository _repository;

  CurrencyInteractor() : _repository = getIt<CurrencyRepository>();

  /// Get all available currencies
  Future<Either<Failure, List<CurrencyEntity>>> getAllCurrencies() async {
    return await _repository.getAllCurrencies();
  }

  /// Get only active currencies for selection
  Future<Either<Failure, List<CurrencyEntity>>> getActiveCurrencies() async {
    return await _repository.getActiveCurrencies();
  }

  /// Get currency by ID
  Future<Either<Failure, CurrencyEntity?>> getCurrencyById(int id) async {
    return await _repository.getCurrencyById(id);
  }

  /// Get currency by code (e.g., 'RUB', 'USD')
  Future<Either<Failure, CurrencyEntity?>> getCurrencyByCode(String code) async {
    if (code.trim().isEmpty) {
      return const Left(ValidationFailure('Currency code cannot be empty'));
    }
    
    return await _repository.getCurrencyByCode(code.trim().toUpperCase());
  }

  /// Get default currency (RUB)
  Future<Either<Failure, CurrencyEntity?>> getDefaultCurrency() async {
    return await getCurrencyByCode('RUB');
  }

  /// Create a new currency
  Future<Either<Failure, int>> createCurrency({
    required String code,
    required String name,
    required String symbol,
    bool isActive = true,
  }) async {
    // Validate inputs
    if (code.trim().isEmpty) {
      return const Left(ValidationFailure('Currency code cannot be empty'));
    }
    
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Currency name cannot be empty'));
    }
    
    if (symbol.trim().isEmpty) {
      return const Left(ValidationFailure('Currency symbol cannot be empty'));
    }

    // Check if currency with this code already exists
    final existingResult = await getCurrencyByCode(code);
    return existingResult.fold(
      (failure) => Left(failure),
      (existing) {
        if (existing != null) {
          return const Left(ValidationFailure('Currency with this code already exists'));
        }

        final currency = CurrenciesCompanion.insert(
          code: code.trim().toUpperCase(),
          name: name.trim(),
          symbol: symbol.trim(),
          isActive: Value(isActive),
        );

        return _repository.insertCurrency(currency);
      },
    );
  }

  /// Update an existing currency
  Future<Either<Failure, bool>> updateCurrency({
    required int id,
    String? code,
    String? name,
    String? symbol,
    bool? isActive,
  }) async {
    final currency = CurrenciesCompanion(
      code: code != null ? Value(code.trim().toUpperCase()) : const Value.absent(),
      name: name != null ? Value(name.trim()) : const Value.absent(),
      symbol: symbol != null ? Value(symbol.trim()) : const Value.absent(),
      isActive: isActive != null ? Value(isActive) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    );

    return await _repository.updateCurrency(id, currency);
  }

  /// Delete a currency
  Future<Either<Failure, int>> deleteCurrency(int id) async {
    return await _repository.deleteCurrency(id);
  }
}
