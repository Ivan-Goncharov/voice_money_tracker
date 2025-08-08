import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/service_locator/service_locator.dart';
import '../../../core/data/database/database.dart';
import '../domain/repository.dart';

/// Implementation of CurrencyRepository using Drift database
/// Handles all currency-related database operations
class CurrencyRepositoryImpl implements CurrencyRepository {
  final AppDatabase _database;

  CurrencyRepositoryImpl() : _database = getIt<AppDatabase>();

  @override
  Future<Either<Failure, List<CurrencyEntity>>> getAllCurrencies() async {
    try {
      final currencies = await _database.currenciesDao.getAllCurrencies();
      return Right(currencies);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get all currencies: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<CurrencyEntity>>> getActiveCurrencies() async {
    try {
      final currencies = await _database.currenciesDao.getActiveCurrencies();
      return Right(currencies);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get active currencies: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CurrencyEntity?>> getCurrencyById(int id) async {
    try {
      final currency = await _database.currenciesDao.getCurrencyById(id);
      return Right(currency);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get currency by ID: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, CurrencyEntity?>> getCurrencyByCode(String code) async {
    try {
      final currency = await _database.currenciesDao.getCurrencyByCode(code);
      return Right(currency);
    } catch (e) {
      return Left(DatabaseFailure('Failed to get currency by code: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> insertCurrency(CurrenciesCompanion currency) async {
    try {
      final id = await _database.currenciesDao.insertCurrency(currency);
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure('Failed to insert currency: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> updateCurrency(int id, CurrenciesCompanion currency) async {
    try {
      final success = await _database.currenciesDao.updateCurrency(id, currency);
      return Right(success);
    } catch (e) {
      return Left(DatabaseFailure('Failed to update currency: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, int>> deleteCurrency(int id) async {
    try {
      final deletedCount = await _database.currenciesDao.deleteCurrency(id);
      return Right(deletedCount);
    } catch (e) {
      return Left(DatabaseFailure('Failed to delete currency: ${e.toString()}'));
    }
  }
}
