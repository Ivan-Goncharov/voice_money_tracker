import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_tracker_2/features/add_expense/presentation/blocs/date_selection_cubit/date_selection_cubit.dart';
import '../../features/onboarding/presentation/screens/home_screen.dart';
import '../../features/add_expense/presentation/widgets/add_expense_modal.dart';
import '../../features/add_expense/presentation/blocs/add_expense_bloc/add_expense_modal_bloc.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/currency/presentation/bloc/currency_bloc.dart';
import '../../features/analytics/presentation/bloc/analytics_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'navigation_bloc.dart';
import 'app_route_state.dart';
import 'page_config.dart';

class AppRouterDelegate extends RouterDelegate<AppRouteState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRouteState> {
  final NavigationBloc navigationBloc;

  // Global Blocs that are used across multiple pages
  final CategoryBloc categoryBloc;
  final ExpenseBloc expenseBloc;
  final CurrencyBloc currencyBloc;
  final AnalyticsBloc analyticsBloc;

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate({
    required this.navigationBloc,
    required this.categoryBloc,
    required this.expenseBloc,
    required this.currencyBloc,
    required this.analyticsBloc,
  }) : navigatorKey = GlobalKey<NavigatorState>() {
    navigationBloc.stream.listen((_) => notifyListeners());
  }

  @override
  AppRouteState get currentConfiguration => navigationBloc.state;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationBloc, AppRouteState>(
      builder: (context, state) {
        return Navigator(
          key: navigatorKey,
          pages: _buildPages(state),
          onDidRemovePage: _onDidRemovePage,
        );
      },
    );
  }

  List<Page> _buildPages(AppRouteState state) {
    final pages = <Page>[];

    // Build main pages from navigation stack
    for (final pageConfig in state.pages) {
      pages.add(_buildPageFromConfig(pageConfig));
    }

    // Add modal pages if needed
    if (state.showExpenseModal) {
      pages.add(_buildExpenseModalPage(state));
    }

    return pages;
  }

  Page _buildPageFromConfig(PageConfig config) {
    switch (config.path) {
      case '/home':
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: BlocProvider(
            create: (context) => OnboardingBloc(),
            child: const HomeScreen(),
          ),
        );

      case '/expenses':
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: const Scaffold(
            appBar: null,
            body: Center(child: Text('Expense List Screen')),
          ),
        );

      case '/categories':
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: const Scaffold(
            appBar: null,
            body: Center(child: Text('Categories Screen')),
          ),
        );

      default:
        if (config.path.startsWith('/expense/')) {
          final expenseId = config.getParam<int>('expenseId');
          return MaterialPage(
            key: ValueKey(config.pageKey),
            child: Scaffold(
              appBar: AppBar(title: Text('Expense Details $expenseId')),
              body: Center(child: Text('Expense Details for ID: $expenseId')),
            ),
          );
        }

        // Fallback to home
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: BlocProvider(
            create: (context) => OnboardingBloc(),
            child: const HomeScreen(),
          ),
        );
    }
  }

  Page _buildExpenseModalPage(AppRouteState state) {
    return ModalBottomSheetPage(
      key: const ValueKey('expense_modal'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => OnboardingBloc()),
          BlocProvider.value(value: expenseBloc),
          BlocProvider.value(value: categoryBloc),
          BlocProvider.value(value: currencyBloc),
          BlocProvider.value(value: analyticsBloc),
          BlocProvider.value(value: navigationBloc),
          BlocProvider(create: (_) => DateSelectionCubit(DateTime.now())),
          BlocProvider(create: (_) => AddExpenseModalBloc()),
        ],
        child: const AddExpenseModal(),
      ),
    );
  }

  void _onDidRemovePage(Page page) {
    // Handle modal dismissal
    if (navigationBloc.state.showExpenseModal &&
        page.key == const ValueKey('expense_modal')) {
      navigationBloc.add(const HideExpenseModal());
      return;
    }

    // Handle regular page navigation
    if (navigationBloc.state.canPop) {
      navigationBloc.add(const PopPage());
    }
  }

  @override
  Future<void> setNewRoutePath(AppRouteState configuration) async {
    // This would be used for deep linking and URL parsing
    // For now, we'll keep it simple
  }

  @override
  void dispose() {
    categoryBloc.close();
    expenseBloc.close();
    super.dispose();
  }
}

/// Custom page for modal bottom sheets
class ModalBottomSheetPage extends Page {
  final Widget child;

  const ModalBottomSheetPage({required this.child, super.key});

  @override
  Route createRoute(BuildContext context) {
    return ModalBottomSheetRoute(
      settings: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => child,
    );
  }
}
