part of 'theme_bloc.dart';

/// Events for ThemeBloc
sealed class ThemeEvent {
  const ThemeEvent();
}

/// Load current theme from storage
final class LoadTheme extends ThemeEvent {
  const LoadTheme();
}

/// Change theme mode
final class ChangeTheme extends ThemeEvent {
  const ChangeTheme(this.themeMode);

  final ThemeMode themeMode;
}
