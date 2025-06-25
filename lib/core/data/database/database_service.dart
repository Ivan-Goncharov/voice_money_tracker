import 'app_database.dart';
import 'categories_dao_interface.dart';
import 'expenses_dao_interface.dart';

/// Database service that provides access to DAOs and manages database lifecycle
/// This service acts as a single point of access to the database
class DatabaseService {
  static DatabaseService? _instance;
  static AppDatabase? _database;

  DatabaseService._();

  /// Singleton instance
  static DatabaseService get instance {
    _instance ??= DatabaseService._();
    return _instance!;
  }

  /// Get the database instance
  AppDatabase get database {
    _database ??= AppDatabase();
    return _database!;
  }

  /// Categories DAO interface
  CategoriesDaoInterface get categoriesDao => database.categoriesDao;

  /// Expenses DAO interface
  ExpensesDaoInterface get expensesDao => database.expensesDao;

  /// Close the database connection
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }

  /// Reset the database service (useful for testing)
  static void reset() {
    _database?.close();
    _database = null;
    _instance = null;
  }
}
