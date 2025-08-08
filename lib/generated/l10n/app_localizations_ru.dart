// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Трекер Расходов';

  @override
  String get analytics => 'Аналитика';

  @override
  String get settings => 'Настройки';

  @override
  String get currentBalance => 'Текущий баланс';

  @override
  String get expenses => 'Расходы';

  @override
  String get income => 'Доходы';

  @override
  String get thisMonth => 'В этом месяце';

  @override
  String get expensesByCategory => 'Расходы по категориям';

  @override
  String get recentTransactions => 'Последние транзакции';

  @override
  String get viewAll => 'Показать все';

  @override
  String get noRecentTransactions => 'Нет последних транзакций';

  @override
  String get noExpenseData => 'Нет данных о расходах';

  @override
  String get addExpense => 'Добавить расход';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get theme => 'Тема';

  @override
  String get language => 'Язык';

  @override
  String get systemDefault => 'Как в системе';

  @override
  String get light => 'Светлая';

  @override
  String get dark => 'Темная';

  @override
  String get chooseTheme => 'Выберите тему';

  @override
  String get chooseLanguage => 'Выберите язык';

  @override
  String get data => 'Данные';

  @override
  String get backupSync => 'Резервное копирование';

  @override
  String get exportYourData => 'Экспорт ваших данных';

  @override
  String get clearData => 'Очистить данные';

  @override
  String get resetAllData => 'Сбросить все данные';

  @override
  String get about => 'О приложении';

  @override
  String get version => 'Версия';

  @override
  String get privacyPolicy => 'Политика конфиденциальности';

  @override
  String get howWeHandleData => 'Как мы обрабатываем ваши данные';

  @override
  String get backupData => 'Резервное копирование';

  @override
  String get exportDataDescription =>
      'Экспортируйте ваши данные в файл для резервного копирования.';

  @override
  String get clearAllData => 'Очистить все данные';

  @override
  String get clearDataWarning =>
      'Это навсегда удалит все ваши расходы, категории и настройки. Это действие нельзя отменить.';

  @override
  String get cancel => 'Отмена';

  @override
  String get export => 'Экспорт';

  @override
  String get close => 'Закрыть';

  @override
  String get privacyPolicyText =>
      'Money Tracker уважает вашу конфиденциальность. Все данные хранятся локально на вашем устройстве и не передаются третьим лицам.\\n\\nМы не собираем, не храним и не передаем никакую личную информацию.\\n\\nВаши финансовые данные остаются приватными и защищенными на вашем устройстве.';

  @override
  String get errorLoadingAnalytics => 'Ошибка загрузки аналитики';

  @override
  String get retry => 'Повторить';

  @override
  String get unknownCategory => 'Неизвестная категория';
}
