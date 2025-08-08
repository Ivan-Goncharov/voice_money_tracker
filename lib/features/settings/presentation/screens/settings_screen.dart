import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_bloc.dart';
import '../bloc/settings_bloc.dart';

/// Settings screen for app preferences
/// Allows users to configure language, theme, and other preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: BlocConsumer<SettingsBloc, SettingsState>(
            listener: (context, state) {
              if (state is SettingsError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.message}'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              } else if (state is DataExported) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Data exported to: ${state.filePath}'),
                    backgroundColor: AppTheme.success,
                  ),
                );
              } else if (state is DataCleared) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                    backgroundColor: AppTheme.warning,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is SettingsLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final settingsLoaded = state is SettingsLoaded ? state : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    // Appearance Section
                    _buildSectionCard(
                      context,
                      title: 'Appearance',
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          subtitle: _getThemeModeText(
                            settingsLoaded?.themeMode,
                          ),
                          onTap:
                              () => _showThemeDialog(
                                context,
                                settingsLoaded?.themeMode,
                              ),
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          context,
                          icon: Icons.language_outlined,
                          title: 'Language',
                          subtitle: _getLanguageText(
                            settingsLoaded?.languageCode,
                          ),
                          onTap:
                              () => _showLanguageDialog(
                                context,
                                settingsLoaded?.languageCode,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Data Section
                    _buildSectionCard(
                      context,
                      title: 'Data',
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.backup_outlined,
                          title: 'Backup & Sync',
                          subtitle: 'Export your data',
                          onTap: () => _showBackupDialog(context),
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          context,
                          icon: Icons.delete_outline,
                          title: 'Clear Data',
                          subtitle: 'Reset all data',
                          onTap: () => _showClearDataDialog(context),
                          isDestructive: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // About Section
                    _buildSectionCard(
                      context,
                      title: 'About',
                      children: [
                        _buildSettingItem(
                          context,
                          icon: Icons.info_outline,
                          title: 'Version',
                          subtitle: '1.0.0',
                          onTap: null,
                        ),
                        const Divider(height: 1),
                        _buildSettingItem(
                          context,
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'How we handle your data',
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _getThemeModeText(ThemeMode? themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
      case null:
        return 'System default';
    }
  }

  String _getLanguageText(String? languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case null:
        return 'System default';
      default:
        return languageCode ?? 'System default';
    }
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppTheme.error : AppTheme.primaryBlue,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: isDestructive ? AppTheme.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
      ),
      trailing:
          onTap != null
              ? const Icon(Icons.chevron_right, color: AppTheme.textSecondary)
              : null,
      onTap: onTap,
    );
  }

  void _showThemeDialog(BuildContext context, ThemeMode? currentTheme) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Theme'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_auto),
                  title: const Text('System Default'),
                  trailing:
                      (currentTheme == ThemeMode.system || currentTheme == null)
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const ChangeThemeMode(ThemeMode.system),
                    );
                    context.read<ThemeBloc>().add(
                      const ChangeTheme(ThemeMode.system),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.light_mode),
                  title: const Text('Light'),
                  trailing:
                      currentTheme == ThemeMode.light
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const ChangeThemeMode(ThemeMode.light),
                    );
                    context.read<ThemeBloc>().add(
                      const ChangeTheme(ThemeMode.light),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark'),
                  trailing:
                      currentTheme == ThemeMode.dark
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const ChangeThemeMode(ThemeMode.dark),
                    );
                    context.read<ThemeBloc>().add(
                      const ChangeTheme(ThemeMode.dark),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showLanguageDialog(BuildContext context, String? currentLanguage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Choose Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('System Default'),
                  trailing:
                      currentLanguage == null
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const ChangeLanguage(null),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('English'),
                  trailing:
                      currentLanguage == 'en'
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const ChangeLanguage('en'),
                    );
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text('Русский'),
                  trailing:
                      currentLanguage == 'ru'
                          ? const Icon(Icons.check, color: AppTheme.primaryBlue)
                          : null,
                  onTap: () {
                    context.read<SettingsBloc>().add(
                      const ChangeLanguage('ru'),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showBackupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Backup Data'),
            content: const Text(
              'Export your data to a file for backup purposes.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SettingsBloc>().add(const ExportData());
                },
                child: const Text('Export'),
              ),
            ],
          ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Clear All Data'),
            content: const Text(
              'This will permanently delete all your expenses, categories, and settings. This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<SettingsBloc>().add(const ClearAllData());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.error,
                ),
                child: const Text('Clear Data'),
              ),
            ],
          ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Privacy Policy'),
            content: const SingleChildScrollView(
              child: Text(
                'Money Tracker respects your privacy. All data is stored locally on your device and is not shared with third parties.\n\n'
                'We do not collect, store, or transmit any personal information.\n\n'
                'Your financial data remains private and secure on your device.',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
