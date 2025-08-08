import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../service_locator/service_locator.dart';
import '../../features/settings/domain/interactors/settings_interactor.dart';

part 'theme_event.dart';
part 'theme_state.dart';

/// BLoC for managing app theme
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SettingsInteractor _settingsInteractor;

  ThemeBloc()
      : _settingsInteractor = getIt<SettingsInteractor>(),
        super(const ThemeState(ThemeMode.system)) {
    on<LoadTheme>(_onLoadTheme);
    on<ChangeTheme>(_onChangeTheme);
  }

  /// Load current theme from storage
  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      final themeMode = await _settingsInteractor.getThemeMode();
      emit(ThemeState(themeMode));
    } catch (e) {
      // If loading fails, use system default
      emit(const ThemeState(ThemeMode.system));
    }
  }

  /// Change theme and save to storage
  Future<void> _onChangeTheme(
    ChangeTheme event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      await _settingsInteractor.setThemeMode(event.themeMode);
      emit(ThemeState(event.themeMode));
    } catch (e) {
      // If saving fails, still emit the new theme
      emit(ThemeState(event.themeMode));
    }
  }
}
