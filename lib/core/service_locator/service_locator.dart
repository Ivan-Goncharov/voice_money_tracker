import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../data/database/database.dart';

// Onboarding
import '../../features/onboarding/domain/repository.dart';
import '../../features/onboarding/data/repository_impl.dart';
import '../../features/onboarding/domain/interactors/onboarding_interactor.dart';

// Category
import '../../features/category/domain/repository.dart';
import '../../features/category/data/repository_impl.dart';
import '../../features/category/domain/interactors/category_interactor.dart';

// Currency
import '../../features/currency/domain/repository.dart';
import '../../features/currency/data/repository_impl.dart';
import '../../features/currency/domain/interactors/currency_interactor.dart';

// Expense
import '../../features/expense/domain/repository.dart';
import '../../features/expense/data/repository_impl.dart';
import '../../features/expense/domain/interactors/expense_interactor.dart';

// Analytics
import '../../features/analytics/domain/interactors/analytics_interactor.dart';

// Settings
import '../../features/settings/domain/interactors/settings_interactor.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // Register core dependencies
  await _registerCore();
  _registerTheme();

  // Register feature dependencies
  _registerOnboarding();
  _registerCategory();
  _registerCurrency();
  _registerExpense();
  _registerAnalytics();
  _registerSettings();
}

/// Register core dependencies (database, shared preferences, etc.)
Future<void> _registerCore() async {
  // Register AppDatabase as a lazy singleton
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Register SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
}

/// Register onboarding feature dependencies
void _registerOnboarding() {
  // Repository
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(),
  );

  // Interactor
  getIt.registerLazySingleton<OnboardingInteractor>(
    () => OnboardingInteractor(),
  );
}

/// Register category feature dependencies
void _registerCategory() {
  // Repository
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(),
  );

  // Interactor
  getIt.registerLazySingleton<CategoryInteractor>(() => CategoryInteractor());

}

/// Register currency feature dependencies
void _registerCurrency() {
  // Repository
  getIt.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(),
  );

  // Interactor
  getIt.registerLazySingleton<CurrencyInteractor>(() => CurrencyInteractor());

}

/// Register expense feature dependencies
void _registerExpense() {
  // Repository
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());

  // Interactor
  getIt.registerLazySingleton<ExpenseInteractor>(() => ExpenseInteractor());

}

/// Register analytics feature dependencies
void _registerAnalytics() {
  // Interactor
  getIt.registerLazySingleton<AnalyticsInteractor>(() => AnalyticsInteractor());

}

/// Register settings feature dependencies
void _registerSettings() {
  // Interactor
  getIt.registerLazySingleton<SettingsInteractor>(() => SettingsInteractor());

}

/// Register theme dependencies
void _registerTheme() {
  // BLoC
}
