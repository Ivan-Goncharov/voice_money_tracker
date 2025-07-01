import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'app_route_state.dart';
import 'page_config.dart';

// Events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

class NavigateToHome extends NavigationEvent {
  const NavigateToHome();
}

class NavigateToExpenseList extends NavigationEvent {
  const NavigateToExpenseList();
}

class NavigateToExpenseDetails extends NavigationEvent {
  final int expenseId;

  const NavigateToExpenseDetails(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class NavigateToCategories extends NavigationEvent {
  const NavigateToCategories();
}

class ShowCreateExpenseModal extends NavigationEvent {
  const ShowCreateExpenseModal();
}

class ShowEditExpenseModal extends NavigationEvent {
  final int expenseId;

  const ShowEditExpenseModal(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class HideExpenseModal extends NavigationEvent {
  const HideExpenseModal();
}

class NavigateBack extends NavigationEvent {
  const NavigateBack();
}

class ResetToHome extends NavigationEvent {
  const ResetToHome();
}

class PushPage extends NavigationEvent {
  final PageConfig page;

  const PushPage(this.page);

  @override
  List<Object?> get props => [page];
}

class PopPage extends NavigationEvent {
  const PopPage();
}

class ReplacePage extends NavigationEvent {
  final PageConfig page;

  const ReplacePage(this.page);

  @override
  List<Object?> get props => [page];
}

// Bloc
class NavigationBloc extends Bloc<NavigationEvent, AppRouteState> {
  NavigationBloc() : super(AppRouteState.initial()) {
    on<NavigateToHome>(_onNavigateToHome);
    on<NavigateToExpenseList>(_onNavigateToExpenseList);
    on<NavigateToExpenseDetails>(_onNavigateToExpenseDetails);
    on<NavigateToCategories>(_onNavigateToCategories);
    on<ShowCreateExpenseModal>(_onShowCreateExpenseModal);
    on<ShowEditExpenseModal>(_onShowEditExpenseModal);
    on<HideExpenseModal>(_onHideExpenseModal);
    on<NavigateBack>(_onNavigateBack);
    on<ResetToHome>(_onResetToHome);
    on<PushPage>(_onPushPage);
    on<PopPage>(_onPopPage);
    on<ReplacePage>(_onReplacePage);
  }

  void _onNavigateToHome(NavigateToHome event, Emitter<AppRouteState> emit) {
    final homePage = PageConfig.withGeneratedKey(path: '/home');
    emit(state.resetToPage(homePage));
  }

  void _onNavigateToExpenseList(NavigateToExpenseList event, Emitter<AppRouteState> emit) {
    final expenseListPage = PageConfig.withGeneratedKey(path: '/expenses');
    emit(state.pushPage(expenseListPage));
  }

  void _onNavigateToExpenseDetails(NavigateToExpenseDetails event, Emitter<AppRouteState> emit) {
    final expenseDetailsPage = PageConfig.withGeneratedKey(
      path: '/expense/${event.expenseId}',
      params: {'expenseId': event.expenseId},
    );
    emit(state.pushPage(expenseDetailsPage));
  }

  void _onNavigateToCategories(NavigateToCategories event, Emitter<AppRouteState> emit) {
    final categoriesPage = PageConfig.withGeneratedKey(path: '/categories');
    emit(state.pushPage(categoriesPage));
  }

  void _onShowCreateExpenseModal(ShowCreateExpenseModal event, Emitter<AppRouteState> emit) {
    emit(state.showCreateExpenseModal());
  }

  void _onShowEditExpenseModal(ShowEditExpenseModal event, Emitter<AppRouteState> emit) {
    emit(state.showEditExpenseModal(event.expenseId));
  }

  void _onHideExpenseModal(HideExpenseModal event, Emitter<AppRouteState> emit) {
    emit(state.hideExpenseModal());
  }

  void _onNavigateBack(NavigateBack event, Emitter<AppRouteState> emit) {
    if (state.canPop) {
      emit(state.popPage());
    }
  }

  void _onResetToHome(ResetToHome event, Emitter<AppRouteState> emit) {
    final homePage = PageConfig.withGeneratedKey(path: '/home');
    emit(state.resetToPage(homePage).hideExpenseModal());
  }

  void _onPushPage(PushPage event, Emitter<AppRouteState> emit) {
    emit(state.pushPage(event.page));
  }

  void _onPopPage(PopPage event, Emitter<AppRouteState> emit) {
    if (state.canPop) {
      emit(state.popPage());
    }
  }

  void _onReplacePage(ReplacePage event, Emitter<AppRouteState> emit) {
    emit(state.replacePage(event.page));
  }
}
