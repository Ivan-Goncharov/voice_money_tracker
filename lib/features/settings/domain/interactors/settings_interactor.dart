import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/service_locator/service_locator.dart';
import '../../../../core/data/database/database.dart';

/// Interactor for settings business logic
/// Handles theme, language, and other app preferences
class SettingsInteractor {
  final SharedPreferences _prefs;
  final AppDatabase _database;

  static const String _themeModeKey = 'theme_mode';
  static const String _languageCodeKey = 'language_code';

  SettingsInteractor()
      : _prefs = getIt<SharedPreferences>(),
        _database = getIt<AppDatabase>();

  /// Get current theme mode
  Future<ThemeMode> getThemeMode() async {
    final themeModeIndex = _prefs.getInt(_themeModeKey);
    if (themeModeIndex == null) {
      return ThemeMode.system;
    }
    return ThemeMode.values[themeModeIndex];
  }

  /// Set theme mode
  Future<void> setThemeMode(ThemeMode themeMode) async {
    await _prefs.setInt(_themeModeKey, themeMode.index);
  }

  /// Get current language code
  Future<String?> getLanguageCode() async {
    return _prefs.getString(_languageCodeKey);
  }

  /// Set language code (null for system default)
  Future<void> setLanguageCode(String? languageCode) async {
    if (languageCode == null) {
      await _prefs.remove(_languageCodeKey);
    } else {
      await _prefs.setString(_languageCodeKey, languageCode);
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    await _prefs.remove(_themeModeKey);
    await _prefs.remove(_languageCodeKey);
  }

  /// Export data to a file
  Future<String> exportData() async {
    // TODO: Implement actual data export functionality
    // For now, just return a placeholder path
    await Future.delayed(const Duration(seconds: 1)); // Simulate export process
    return '/path/to/exported/data.json';
  }

  /// Clear all application data
  Future<void> clearAllData() async {
    // Clear database
    await _database.close();
    
    // Clear shared preferences (except critical system settings)
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (!key.startsWith('flutter.')) { // Keep Flutter framework settings
        await _prefs.remove(key);
      }
    }
    
    // Reinitialize database
    // Note: In a real app, you might want to delete the database file
    // and recreate it, but for simplicity we'll just clear the tables
    await _clearDatabaseTables();
  }

  /// Clear all database tables
  Future<void> _clearDatabaseTables() async {
    // Delete all expenses
    await _database.delete(_database.expenses).go();
    
    // Delete all categories (except default ones)
    await _database.delete(_database.categories).go();
    
    // Recreate default categories
    await _createDefaultCategories();
  }

  /// Create default categories
  Future<void> _createDefaultCategories() async {
    final defaultCategories = [
      CategoriesCompanion.insert(
        name: 'Food & Dining',
        description: const Value('Restaurants, groceries, and food expenses'),
        color: '#FF6B6B',
        iconCodePoint: 0xe57c, // food icon
      ),
      CategoriesCompanion.insert(
        name: 'Transportation',
        description: const Value('Car, gas, public transport, and travel'),
        color: '#4ECDC4',
        iconCodePoint: 0xe530, // directions_car icon
      ),
      CategoriesCompanion.insert(
        name: 'Shopping',
        description: const Value('Clothes, electronics, and general shopping'),
        color: '#45B7D1',
        iconCodePoint: 0xe59c, // shopping_bag icon
      ),
      CategoriesCompanion.insert(
        name: 'Entertainment',
        description: const Value('Movies, games, and entertainment'),
        color: '#96CEB4',
        iconCodePoint: 0xe03e, // movie icon
      ),
      CategoriesCompanion.insert(
        name: 'Bills & Utilities',
        description: const Value('Rent, electricity, water, and other bills'),
        color: '#FECA57',
        iconCodePoint: 0xe0e4, // receipt icon
      ),
      CategoriesCompanion.insert(
        name: 'Healthcare',
        description: const Value('Medical expenses and healthcare'),
        color: '#FF9FF3',
        iconCodePoint: 0xe1c6, // local_hospital icon
      ),
    ];

    await _database.batch((batch) {
      batch.insertAll(_database.categories, defaultCategories);
    });
  }

  /// Get app version
  String getAppVersion() {
    return '1.0.0'; // TODO: Get from package info
  }

  /// Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    const key = 'first_launch';
    final isFirst = !_prefs.containsKey(key);
    if (isFirst) {
      await _prefs.setBool(key, false);
    }
    return isFirst;
  }
}
