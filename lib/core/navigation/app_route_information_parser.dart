import 'package:flutter/material.dart';
import 'app_route_state.dart';
import 'page_config.dart';

class AppRouteInformationParser extends RouteInformationParser<AppRouteState> {
  @override
  Future<AppRouteState> parseRouteInformation(RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location ?? '/');
    
    // Parse the path and create appropriate page configuration
    final path = uri.path;
    final queryParams = uri.queryParameters;
    
    // Handle different routes
    switch (path) {
      case '/':
      case '/home':
        return AppRouteState(
          pages: [PageConfig.withGeneratedKey(path: '/home')],
          showExpenseModal: queryParams.containsKey('add_expense'),
        );
      
      case '/expenses':
        return AppRouteState(
          pages: [
            PageConfig.withGeneratedKey(path: '/home'),
            PageConfig.withGeneratedKey(path: '/expenses'),
          ],
        );
      
      case '/categories':
        return AppRouteState(
          pages: [
            PageConfig.withGeneratedKey(path: '/home'),
            PageConfig.withGeneratedKey(path: '/categories'),
          ],
        );
      
      default:
        // Handle expense details routes like /expense/123
        if (path.startsWith('/expense/')) {
          final expenseIdStr = path.split('/').last;
          final expenseId = int.tryParse(expenseIdStr);
          
          if (expenseId != null) {
            return AppRouteState(
              pages: [
                PageConfig.withGeneratedKey(path: '/home'),
                PageConfig.withGeneratedKey(path: '/expenses'),
                PageConfig.withGeneratedKey(
                  path: '/expense/$expenseId',
                  params: {'expenseId': expenseId},
                ),
              ],
              showExpenseModal: queryParams.containsKey('edit'),
              editingExpenseId: queryParams.containsKey('edit') ? expenseId : null,
            );
          }
        }
        
        // Fallback to home
        return AppRouteState.initial();
    }
  }

  @override
  RouteInformation? restoreRouteInformation(AppRouteState state) {
    // Convert app state back to URL for browser address bar
    final currentPage = state.currentPage;
    
    if (currentPage == null) {
      return const RouteInformation(location: '/home');
    }
    
    String location = currentPage.path;
    
    // Add query parameters for modal states
    final queryParams = <String, String>{};
    
    if (state.showExpenseModal) {
      if (state.isEditingExpense) {
        queryParams['edit'] = 'true';
      } else {
        queryParams['add_expense'] = 'true';
      }
    }
    
    if (queryParams.isNotEmpty) {
      final uri = Uri.parse(location);
      final newUri = uri.replace(queryParameters: queryParams);
      location = newUri.toString();
    }
    
    return RouteInformation(location: location);
  }
}
