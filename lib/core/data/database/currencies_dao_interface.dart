import 'app_database.dart';

/// Interface for Currencies Data Access Object
/// This abstraction allows repositories to work with currencies data
/// without directly depending on Drift implementation details
abstract interface class CurrenciesDaoInterface {
  /// Get all currencies from the database
  Future<List<CurrencyEntity>> getAllCurrencies();

  /// Get only active currencies (isActive = true)
  Future<List<CurrencyEntity>> getActiveCurrencies();

  /// Get a specific currency by ID
  Future<CurrencyEntity?> getCurrencyById(int id);

  /// Get a specific currency by code
  Future<CurrencyEntity?> getCurrencyByCode(String code);

  /// Insert a new currency
  Future<int> insertCurrency(CurrenciesCompanion currency);

  /// Update an existing currency
  Future<bool> updateCurrency(int id, CurrenciesCompanion currency);

  /// Delete a currency permanently
  Future<int> deleteCurrency(int id);
}
