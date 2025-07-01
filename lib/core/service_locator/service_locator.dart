import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../data/database/database.dart';

// Onboarding
import '../../features/onboarding/domain/repository.dart';
import '../../features/onboarding/data/repository_impl.dart';
import '../../features/onboarding/domain/interactors/onboarding_interactor.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';

// Category
import '../../features/category/domain/repository.dart';
import '../../features/category/data/repository_impl.dart';
import '../../features/category/domain/interactors/category_interactor.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';

// Expense
import '../../features/expense/domain/repository.dart';
import '../../features/expense/data/repository_impl.dart';
import '../../features/expense/domain/interactors/expense_interactor.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> init() async {
  // Register core dependencies
  await _registerCore();

  // Register feature dependencies
  _registerOnboarding();
  _registerCategory();
  _registerExpense();
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

  // BLoC
  getIt.registerFactory<OnboardingBloc>(() => OnboardingBloc());
}

/// Register category feature dependencies
void _registerCategory() {
  // Repository
  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(),
  );

  // Interactor
  getIt.registerLazySingleton<CategoryInteractor>(() => CategoryInteractor());

  // BLoC
  getIt.registerFactory<CategoryBloc>(() => CategoryBloc());
}

/// Register expense feature dependencies
void _registerExpense() {
  // Repository
  getIt.registerLazySingleton<ExpenseRepository>(() => ExpenseRepositoryImpl());

  // Interactor
  getIt.registerLazySingleton<ExpenseInteractor>(() => ExpenseInteractor());

  // BLoC
  getIt.registerFactory<ExpenseBloc>(() => ExpenseBloc());
}
