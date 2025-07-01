import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'categories_dao_interface.dart';
import 'expenses_dao_interface.dart';

part 'app_database.g.dart';

// Tables
@DataClassName('CategoryEntity')
class Categories extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  TextColumn get color => text().withLength(min: 6, max: 7)(); // Hex color code
  IntColumn get iconCodePoint => integer()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('ExpenseEntity')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get amount => real()();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  IntColumn get categoryId => integer().references(Categories, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringType => text().nullable()(); // daily, weekly, monthly, yearly
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

// DAOs
@DriftAccessor(tables: [Categories])
class CategoriesDao extends DatabaseAccessor<AppDatabase> with _$CategoriesDaoMixin implements CategoriesDaoInterface {
  CategoriesDao(super.db);

  @override
  Future<List<CategoryEntity>> getAllCategories() => select(categories).get();

  @override
  Future<List<CategoryEntity>> getActiveCategories() =>
      (select(categories)..where((tbl) => tbl.isActive.equals(true))).get();

  @override
  Future<CategoryEntity?> getCategoryById(int id) =>
      (select(categories)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  @override
  Future<int> insertCategory(CategoriesCompanion category) =>
      into(categories).insert(category);

  @override
  Future<bool> updateCategory(int id, CategoriesCompanion category) async {
    final result = await (update(categories)..where((tbl) => tbl.id.equals(id))).write(category);
    return result > 0;
  }

  @override
  Future<int> deleteCategory(int id) =>
      (delete(categories)..where((tbl) => tbl.id.equals(id))).go();

  @override
  Future<bool> deactivateCategory(int id) async {
    final result = await (update(categories)
          ..where((tbl) => tbl.id.equals(id)))
        .write(CategoriesCompanion(
          isActive: const Value(false),
          updatedAt: Value(DateTime.now()),
        ));
    return result > 0;
  }

  @override
  Stream<List<CategoryEntity>> watchActiveCategories() =>
      (select(categories)..where((tbl) => tbl.isActive.equals(true))).watch();
}

@DriftAccessor(tables: [Expenses, Categories])
class ExpensesDao extends DatabaseAccessor<AppDatabase> with _$ExpensesDaoMixin implements ExpensesDaoInterface {
  ExpensesDao(super.db);

  @override
  Future<List<ExpenseEntity>> getAllExpenses() => select(expenses).get();

  @override
  Future<List<ExpenseEntity>> getExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) =>
      (select(expenses)
            ..where((tbl) => tbl.date.isBetweenValues(startDate, endDate))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
          .get();

  @override
  Future<List<ExpenseEntity>> getExpensesByCategory(int categoryId) =>
      (select(expenses)
            ..where((tbl) => tbl.categoryId.equals(categoryId))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
          .get();

  @override
  Future<ExpenseEntity?> getExpenseById(int id) =>
      (select(expenses)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  @override
  Future<int> insertExpense(ExpensesCompanion expense) =>
      into(expenses).insert(expense);

  @override
  Future<bool> updateExpense(int id, ExpensesCompanion expense) async {
    final result = await (update(expenses)..where((tbl) => tbl.id.equals(id))).write(expense);
    return result > 0;
  }

  @override
  Future<int> deleteExpense(int id) =>
      (delete(expenses)..where((tbl) => tbl.id.equals(id))).go();

  @override
  Future<double> getTotalExpensesByCategory(int categoryId) async {
    final query = selectOnly(expenses)
      ..where(expenses.categoryId.equals(categoryId))
      ..addColumns([expenses.amount.sum()]);

    final result = await query.getSingleOrNull();
    return result?.read(expenses.amount.sum()) ?? 0.0;
  }

  @override
  Future<double> getTotalExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final query = selectOnly(expenses)
      ..where(expenses.date.isBetweenValues(startDate, endDate))
      ..addColumns([expenses.amount.sum()]);

    final result = await query.getSingleOrNull();
    return result?.read(expenses.amount.sum()) ?? 0.0;
  }

  @override
  Future<List<ExpenseWithCategory>> getExpensesWithCategory() {
    final query = select(expenses).join([
      leftOuterJoin(categories, categories.id.equalsExp(expenses.categoryId)),
    ]);

    return query.map((row) {
      return ExpenseWithCategory(
        expense: row.readTable(expenses),
        category: row.readTableOrNull(categories),
      );
    }).get();
  }

  @override
  Stream<List<ExpenseEntity>> watchExpensesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) =>
      (select(expenses)
            ..where((tbl) => tbl.date.isBetweenValues(startDate, endDate))
            ..orderBy([(tbl) => OrderingTerm.desc(tbl.date)]))
          .watch();
}

// Data class for joined queries
class ExpenseWithCategory {
  final ExpenseEntity expense;
  final CategoryEntity? category;

  ExpenseWithCategory({
    required this.expense,
    this.category,
  });
}

// Database
@DriftDatabase(tables: [Categories, Expenses], daos: [CategoriesDao, ExpensesDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Insert default categories
        await batch((batch) {
          batch.insertAll(categories, [
          CategoriesCompanion.insert(
            name: 'Food & Dining',
            description: const Value('Restaurants, groceries, and food expenses'),
            color: '#FF6B6B',
            iconCodePoint: 0xe57c, // food icon
          ),
          CategoriesCompanion.insert(
            name: 'Transportation',
            description: const Value('Car, gas, public transport, and travel'),
            color: '#4ECDC4',
            iconCodePoint: 0xe530, // directions_car icon
          ),
          CategoriesCompanion.insert(
            name: 'Shopping',
            description: const Value('Clothes, electronics, and general shopping'),
            color: '#45B7D1',
            iconCodePoint: 0xe59c, // shopping_bag icon
          ),
          CategoriesCompanion.insert(
            name: 'Entertainment',
            description: const Value('Movies, games, and entertainment'),
            color: '#96CEB4',
            iconCodePoint: 0xe03e, // movie icon
          ),
          CategoriesCompanion.insert(
            name: 'Bills & Utilities',
            description: const Value('Rent, electricity, water, and other bills'),
            color: '#FECA57',
            iconCodePoint: 0xe0e4, // receipt icon
          ),
          CategoriesCompanion.insert(
            name: 'Healthcare',
            description: const Value('Medical expenses and healthcare'),
            color: '#FF9FF3',
            iconCodePoint: 0xe1c6, // local_hospital icon
          ),
          ]);
        });
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Add migration logic here when schema version changes
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    await getApplicationDocumentsDirectory();
    
    return driftDatabase(
      name: 'money_tracker',
      native: const DriftNativeOptions(shareAcrossIsolates: true),
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  });
}
