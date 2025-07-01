import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/onboarding/presentation/screens/home_screen.dart';
import '../../features/onboarding/presentation/widgets/add_expense_modal.dart';
import '../../features/category/presentation/bloc/category_bloc.dart';
import '../../features/expense/presentation/bloc/expense_bloc.dart';
import '../../features/onboarding/presentation/bloc/onboarding_bloc.dart';
import '../../core/service_locator/service_locator.dart';
import 'navigation_bloc.dart';
import 'app_route_state.dart';
import 'page_config.dart';

class AppRouterDelegate extends RouterDelegate<AppRouteState>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRouteState> {
  
  final NavigationBloc _navigationBloc;
  
  @override
  final GlobalKey<NavigatorState> navigatorKey;

  AppRouterDelegate(this._navigationBloc) : navigatorKey = GlobalKey<NavigatorState>() {
    _navigationBloc.stream.listen((_) => notifyListeners());
  }

  @override
  AppRouteState get currentConfiguration => _navigationBloc.state;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _navigationBloc,
      child: BlocBuilder<NavigationBloc, AppRouteState>(
        builder: (context, state) {
          return Navigator(
            key: navigatorKey,
            pages: _buildPages(state),
            onPopPage: _onPopPage,
          );
        },
      ),
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
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<OnboardingBloc>()),
              BlocProvider(create: (context) => getIt<CategoryBloc>()),
              BlocProvider(create: (context) => getIt<ExpenseBloc>()),
            ],
            child: const HomeScreen(),
          ),
        );
      
      case '/expenses':
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<ExpenseBloc>()),
              BlocProvider(create: (context) => getIt<CategoryBloc>()),
            ],
            child: const Scaffold(
              appBar: null,
              body: Center(
                child: Text('Expense List Screen'),
              ),
            ),
          ),
        );
      
      case '/categories':
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: BlocProvider(
            create: (context) => getIt<CategoryBloc>(),
            child: const Scaffold(
              appBar: null,
              body: Center(
                child: Text('Categories Screen'),
              ),
            ),
          ),
        );
      
      default:
        if (config.path.startsWith('/expense/')) {
          final expenseId = config.getParam<int>('expenseId');
          return MaterialPage(
            key: ValueKey(config.pageKey),
            child: MultiBlocProvider(
              providers: [
                BlocProvider(create: (context) => getIt<ExpenseBloc>()),
                BlocProvider(create: (context) => getIt<CategoryBloc>()),
              ],
              child: Scaffold(
                appBar: AppBar(title: Text('Expense Details $expenseId')),
                body: Center(
                  child: Text('Expense Details for ID: $expenseId'),
                ),
              ),
            ),
          );
        }
        
        // Fallback to home
        return MaterialPage(
          key: ValueKey(config.pageKey),
          child: MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => getIt<OnboardingBloc>()),
              BlocProvider(create: (context) => getIt<CategoryBloc>()),
              BlocProvider(create: (context) => getIt<ExpenseBloc>()),
            ],
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
          BlocProvider(create: (context) => getIt<CategoryBloc>()..add(const LoadActiveCategories())),
          BlocProvider(create: (context) => getIt<ExpenseBloc>()),
          BlocProvider(create: (context) => getIt<OnboardingBloc>()),
        ],
        child: const AddExpenseModal(),
      ),
    );
  }

  bool _onPopPage(Route<dynamic> route, dynamic result) {
    if (!route.didPop(result)) {
      return false;
    }

    // Handle modal dismissal
    if (_navigationBloc.state.showExpenseModal) {
      _navigationBloc.add(const HideExpenseModal());
      return true;
    }

    // Handle regular page navigation
    if (_navigationBloc.state.canPop) {
      _navigationBloc.add(const PopPage());
      return true;
    }

    return false;
  }

  @override
  Future<void> setNewRoutePath(AppRouteState configuration) async {
    // This would be used for deep linking and URL parsing
    // For now, we'll keep it simple
  }
}

/// Custom page for modal bottom sheets
class ModalBottomSheetPage extends Page {
  final Widget child;

  const ModalBottomSheetPage({
    required this.child,
    super.key,
  });

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
