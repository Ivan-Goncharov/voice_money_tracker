part of 'settings_bloc.dart';

/// Events for SettingsBloc
/// Represents all possible events for settings operations
sealed class SettingsEvent {
  const SettingsEvent();
}

/// Load current settings
final class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

/// Change theme mode
final class ChangeThemeMode extends SettingsEvent {
  const ChangeThemeMode(this.themeMode);

  final ThemeMode themeMode;
}

/// Change language
final class ChangeLanguage extends SettingsEvent {
  const ChangeLanguage(this.languageCode);

  final String? languageCode; // null means system default
}

/// Reset all settings to default
final class ResetSettings extends SettingsEvent {
  const ResetSettings();
}

/// Export data
final class ExportData extends SettingsEvent {
  const ExportData();
}

/// Clear all data
final class ClearAllData extends SettingsEvent {
  const ClearAllData();
}
