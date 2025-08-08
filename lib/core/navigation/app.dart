import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/theme_bloc.dart';
import '../service_locator/service_locator.dart';
import '../../generated/l10n/app_localizations.dart';
import 'navigation_bloc.dart';
import 'app_router_delegate.dart';
import 'app_route_information_parser.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/currency/presentation/bloc/currency_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

/// Main application widget with Navigation 2.0
class MoneyTrackerApp extends StatefulWidget {
  const MoneyTrackerApp({super.key});

  @override
  State<MoneyTrackerApp> createState() => _MoneyTrackerAppState();
}

class _MoneyTrackerAppState extends State<MoneyTrackerApp> {
  late final NavigationBloc _navigationBloc;
  late final ThemeBloc _themeBloc;
  late final AnalyticsBloc _analyticsBloc;
  late final OnboardingBloc _onboardingBloc;
  late final ExpenseBloc _expenseBloc;
  late final CategoryBloc _categoryBloc;
  late final CurrencyBloc _currencyBloc;
  late final SettingsBloc _settingsBloc;
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc();
    _themeBloc = ThemeBloc()..add(const LoadTheme());
    _analyticsBloc = AnalyticsBloc();
    _onboardingBloc = OnboardingBloc();
    _expenseBloc = ExpenseBloc();
    _categoryBloc = CategoryBloc();
    _currencyBloc = CurrencyBloc();
    _settingsBloc = SettingsBloc();
    _routerDelegate = AppRouterDelegate(_navigationBloc);
    _routeInformationParser = AppRouteInformationParser();

    // Navigate to home on app start
    _navigationBloc.add(const NavigateToHome());
  }

  @override
  void dispose() {
    _navigationBloc.close();
    _themeBloc.close();
    _analyticsBloc.close();
    _onboardingBloc.close();
    _expenseBloc.close();
    _categoryBloc.close();
    _currencyBloc.close();
    _settingsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _navigationBloc),
        BlocProvider.value(value: _themeBloc),
        BlocProvider.value(value: _analyticsBloc),
        BlocProvider.value(value: _onboardingBloc),
        BlocProvider.value(value: _expenseBloc),
        BlocProvider.value(value: _categoryBloc),
        BlocProvider.value(value: _currencyBloc),
        BlocProvider.value(value: _settingsBloc),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Money Tracker',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            routerDelegate: _routerDelegate,
            routeInformationParser: _routeInformationParser,
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('ru')],
          );
        },
      ),
    );
  }
}
