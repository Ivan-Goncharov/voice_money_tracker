import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/interactors/settings_interactor.dart';
import '../../../../core/service_locator/service_locator.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// BLoC for managing settings operations
/// Handles theme, language, and other app preferences
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsInteractor _interactor;

  SettingsBloc()
      : _interactor = getIt<SettingsInteractor>(),
        super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<ChangeLanguage>(_onChangeLanguage);
    on<ResetSettings>(_onResetSettings);
    on<ExportData>(_onExportData);
    on<ClearAllData>(_onClearAllData);
  }

  /// Handle loading current settings
  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    try {
      final themeMode = await _interactor.getThemeMode();
      final languageCode = await _interactor.getLanguageCode();

      emit(SettingsLoaded(
        themeMode: themeMode,
        languageCode: languageCode,
      ));
    } catch (error) {
      emit(SettingsError(message: error.toString()));
    }
  }

  /// Handle changing theme mode
  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _interactor.setThemeMode(event.themeMode);
      
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(themeMode: event.themeMode));
      }
    } catch (error) {
      emit(SettingsError(message: error.toString()));
    }
  }

  /// Handle changing language
  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _interactor.setLanguageCode(event.languageCode);
      
      if (state is SettingsLoaded) {
        final currentState = state as SettingsLoaded;
        emit(currentState.copyWith(languageCode: event.languageCode));
      }
    } catch (error) {
      emit(SettingsError(message: error.toString()));
    }
  }

  /// Handle resetting settings to default
  Future<void> _onResetSettings(
    ResetSettings event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _interactor.resetToDefaults();
      
      emit(const SettingsLoaded(
        themeMode: ThemeMode.system,
        languageCode: null,
      ));
    } catch (error) {
      emit(SettingsError(message: error.toString()));
    }
  }

  /// Handle exporting data
  Future<void> _onExportData(
    ExportData event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final filePath = await _interactor.exportData();
      emit(DataExported(filePath: filePath));
    } catch (error) {
      emit(SettingsError(message: error.toString()));
    }
  }

  /// Handle clearing all data
  Future<void> _onClearAllData(
    ClearAllData event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await _interactor.clearAllData();
      emit(const DataCleared());
    } catch (error) {
      emit(SettingsError(message: error.toString()));
    }
  }
}
