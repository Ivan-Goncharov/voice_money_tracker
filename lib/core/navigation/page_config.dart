import 'package:equatable/equatable.dart';

/// A value object representing a single page configuration in the navigation stack.
/// Contains the path, a unique page key, and optional parameters.
class PageConfig extends Equatable {
  /// The route path for this page (e.g., '/home', '/expense/123')
  final String path;
  
  /// A unique key identifying this specific page instance
  final String pageKey;
  
  /// Optional parameters associated with this page
  final Map<String, dynamic>? params;
  
  const PageConfig({
    required this.path,
    required this.pageKey,
    this.params,
  });
  
  @override
  List<Object?> get props => [path, pageKey, params];
  
  /// Creates a copy of this PageConfig with optional new values
  PageConfig copyWith({
    String? path,
    String? pageKey,
    Map<String, dynamic>? params,
  }) {
    return PageConfig(
      path: path ?? this.path,
      pageKey: pageKey ?? this.pageKey,
      params: params ?? this.params,
    );
  }
  
  /// Creates a PageConfig with a generated unique page key
  factory PageConfig.withGeneratedKey({
    required String path,
    Map<String, dynamic>? params,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pageKey = '${path}_$timestamp';
    
    return PageConfig(
      path: path,
      pageKey: pageKey,
      params: params,
    );
  }
  
  /// Creates a copy of this PageConfig with updated parameters
  PageConfig updateParams(Map<String, dynamic> newParams) {
    return copyWith(
      params: {
        ...?params,
        ...newParams,
      },
    );
  }
  
  /// Gets a parameter value by key with optional type casting
  T? getParam<T>(String key) {
    final value = params?[key];
    return value is T ? value : null;
  }
  
  /// Checks if this page matches the given path
  bool matchesPath(String otherPath) => path == otherPath;
  
  /// Returns a string representation for debugging
  @override
  String toString() {
    return 'PageConfig(path: $path, pageKey: $pageKey, params: $params)';
  }
}
