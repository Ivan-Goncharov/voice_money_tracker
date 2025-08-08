// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Money Tracker';

  @override
  String get analytics => 'Analytics';

  @override
  String get settings => 'Settings';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get expenses => 'Expenses';

  @override
  String get income => 'Income';

  @override
  String get thisMonth => 'This month';

  @override
  String get expensesByCategory => 'Expenses by Category';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get viewAll => 'View All';

  @override
  String get noRecentTransactions => 'No recent transactions';

  @override
  String get noExpenseData => 'No expense data available';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get language => 'Language';

  @override
  String get systemDefault => 'System default';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get data => 'Data';

  @override
  String get backupSync => 'Backup & Sync';

  @override
  String get exportYourData => 'Export your data';

  @override
  String get clearData => 'Clear Data';

  @override
  String get resetAllData => 'Reset all data';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get howWeHandleData => 'How we handle your data';

  @override
  String get backupData => 'Backup Data';

  @override
  String get exportDataDescription =>
      'Export your data to a file for backup purposes.';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get clearDataWarning =>
      'This will permanently delete all your expenses, categories, and settings. This action cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get export => 'Export';

  @override
  String get close => 'Close';

  @override
  String get privacyPolicyText =>
      'Money Tracker respects your privacy. All data is stored locally on your device and is not shared with third parties.\\n\\nWe do not collect, store, or transmit any personal information.\\n\\nYour financial data remains private and secure on your device.';

  @override
  String get errorLoadingAnalytics => 'Error loading analytics';

  @override
  String get retry => 'Retry';

  @override
  String get unknownCategory => 'Unknown Category';
}
