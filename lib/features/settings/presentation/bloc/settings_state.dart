part of 'settings_bloc.dart';

/// States for SettingsBloc
/// Represents all possible states during settings operations
sealed class SettingsState {
  const SettingsState();
}

/// Initial state when the bloc is created
final class SettingsInitial extends SettingsState {
  const SettingsInitial();
}

/// Loading state while performing settings operations
final class SettingsLoading extends SettingsState {
  const SettingsLoading();
}

/// State with loaded settings
final class SettingsLoaded extends SettingsState {
  const SettingsLoaded({
    required this.themeMode,
    required this.languageCode,
  });

  final ThemeMode themeMode;
  final String? languageCode; // null means system default

  SettingsLoaded copyWith({
    ThemeMode? themeMode,
    String? languageCode,
  }) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}

/// Error state when settings operations fail
final class SettingsError extends SettingsState {
  const SettingsError({required this.message});

  final String message;
}

/// State indicating successful data export
final class DataExported extends SettingsState {
  const DataExported({required this.filePath});

  final String filePath;
}

/// State indicating successful data clearing
final class DataCleared extends SettingsState {
  const DataCleared();
}
