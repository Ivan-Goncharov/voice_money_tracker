import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_theme.dart';
import 'navigation_bloc.dart';
import 'app_router_delegate.dart';
import 'app_route_information_parser.dart';

/// Main application widget with Navigation 2.0
class MoneyTrackerApp extends StatefulWidget {
  const MoneyTrackerApp({super.key});

  @override
  State<MoneyTrackerApp> createState() => _MoneyTrackerAppState();
}

class _MoneyTrackerAppState extends State<MoneyTrackerApp> {
  late final NavigationBloc _navigationBloc;
  late final AppRouterDelegate _routerDelegate;
  late final AppRouteInformationParser _routeInformationParser;

  @override
  void initState() {
    super.initState();
    _navigationBloc = NavigationBloc();
    _routerDelegate = AppRouterDelegate(_navigationBloc);
    _routeInformationParser = AppRouteInformationParser();
    
    // Navigate to home on app start
    _navigationBloc.add(const NavigateToHome());
  }

  @override
  void dispose() {
    _navigationBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _navigationBloc,
      child: MaterialApp.router(
        title: 'Money Tracker',
        theme: AppTheme.lightTheme,
        routerDelegate: _routerDelegate,
        routeInformationParser: _routeInformationParser,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
