import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/data/database/database.dart';

/// Repository interface for currency operations
/// Defines the contract for currency data access
abstract interface class CurrencyRepository {
  /// Get all currencies
  Future<Either<Failure, List<CurrencyEntity>>> getAllCurrencies();

  /// Get only active currencies
  Future<Either<Failure, List<CurrencyEntity>>> getActiveCurrencies();

  /// Get currency by ID
  Future<Either<Failure, CurrencyEntity?>> getCurrencyById(int id);

  /// Get currency by code
  Future<Either<Failure, CurrencyEntity?>> getCurrencyByCode(String code);

  /// Insert a new currency
  Future<Either<Failure, int>> insertCurrency(CurrenciesCompanion currency);

  /// Update an existing currency
  Future<Either<Failure, bool>> updateCurrency(int id, CurrenciesCompanion currency);

  /// Delete a currency
  Future<Either<Failure, int>> deleteCurrency(int id);
}
