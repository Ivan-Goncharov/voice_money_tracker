import 'package:equatable/equatable.dart';

import 'page_config.dart';

/// The single source of truth for the current navigation state of the application.
/// This immutable class holds the complete navigation stack and modal state.
class AppRouteState extends Equatable {
  /// Stack of high-level pages representing the navigation hierarchy
  final List<PageConfig> pages;
  
  /// Whether the expense modal is currently displayed
  final bool showExpenseModal;
  
  /// ID of the expense being edited, null if creating new expense
  final int? editingExpenseId;
  
  const AppRouteState({
    this.pages = const [],
    this.showExpenseModal = false,
    this.editingExpenseId,
  });
  
  @override
  List<Object?> get props => [pages, showExpenseModal, editingExpenseId];
  
  /// Creates a copy of this AppRouteState with optional new values
  AppRouteState copyWith({
    List<PageConfig>? pages,
    bool? showExpenseModal,
    int? editingExpenseId,
  }) {
    return AppRouteState(
      pages: pages ?? this.pages,
      showExpenseModal: showExpenseModal ?? this.showExpenseModal,
      editingExpenseId: editingExpenseId ?? this.editingExpenseId,
    );
  }
  
  /// Creates an initial state with a home page
  factory AppRouteState.initial() {
    return AppRouteState(
      pages: [
        PageConfig.withGeneratedKey(path: '/home'),
      ],
    );
  }
  
  /// Returns the current (top) page in the navigation stack
  PageConfig? get currentPage => pages.isNotEmpty ? pages.last : null;
  
  /// Returns the current route path
  String? get currentPath => currentPage?.path;
  
  /// Returns true if we can navigate back (more than one page in stack)
  bool get canPop => pages.length > 1;
  
  /// Returns true if the expense modal is open for editing
  bool get isEditingExpense => showExpenseModal && editingExpenseId != null;
  
  /// Returns true if the expense modal is open for creating new expense
  bool get isCreatingExpense => showExpenseModal && editingExpenseId == null;
  
  /// Adds a new page to the navigation stack
  AppRouteState pushPage(PageConfig page) {
    return copyWith(
      pages: [...pages, page],
    );
  }
  
  /// Removes the current page from the navigation stack
  AppRouteState popPage() {
    if (pages.length <= 1) return this;
    
    return copyWith(
      pages: pages.sublist(0, pages.length - 1),
    );
  }
  
  /// Replaces the current page with a new one
  AppRouteState replacePage(PageConfig page) {
    if (pages.isEmpty) {
      return copyWith(pages: [page]);
    }
    
    final newPages = List<PageConfig>.from(pages);
    newPages[newPages.length - 1] = page;
    
    return copyWith(pages: newPages);
  }
  
  /// Clears the navigation stack and sets a single page
  AppRouteState resetToPage(PageConfig page) {
    return copyWith(pages: [page]);
  }
  
  /// Pops pages until reaching a page with the specified path
  AppRouteState popToPath(String path) {
    final pageIndex = pages.lastIndexWhere((page) => page.path == path);
    
    if (pageIndex == -1 || pageIndex == pages.length - 1) {
      return this;
    }
    
    return copyWith(
      pages: pages.sublist(0, pageIndex + 1),
    );
  }
  
  /// Shows the expense modal for creating a new expense
  AppRouteState showCreateExpenseModal() {
    return copyWith(
      showExpenseModal: true,
      editingExpenseId: null,
    );
  }
  
  /// Shows the expense modal for editing an existing expense
  AppRouteState showEditExpenseModal(int expenseId) {
    return copyWith(
      showExpenseModal: true,
      editingExpenseId: expenseId,
    );
  }
  
  /// Hides the expense modal
  AppRouteState hideExpenseModal() {
    return copyWith(
      showExpenseModal: false,
      editingExpenseId: null,
    );
  }
  
  /// Updates the current page's parameters
  AppRouteState updateCurrentPageParams(Map<String, dynamic> params) {
    if (pages.isEmpty) return this;
    
    final updatedPage = currentPage!.updateParams(params);
    return replacePage(updatedPage);
  }
  
  /// Finds a page by its path (returns the last matching page)
  PageConfig? findPageByPath(String path) {
    try {
      return pages.lastWhere((page) => page.path == path);
    } catch (_) {
      return null;
    }
  }
  
  /// Returns true if a page with the given path exists in the stack
  bool hasPageWithPath(String path) {
    return pages.any((page) => page.path == path);
  }
  
  /// Returns a debug-friendly string representation
  @override
  String toString() {
    return 'AppRouteState(\n'
        '  pages: ${pages.map((p) => p.path).toList()},\n'
        '  showExpenseModal: $showExpenseModal,\n'
        '  editingExpenseId: $editingExpenseId\n'
        ')';
  }
}
