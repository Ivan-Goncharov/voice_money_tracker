import 'package:flutter/material.dart';
import 'core/service_locator/service_locator.dart' as service_locator;
import 'core/navigation/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await service_locator.init();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MoneyTrackerApp();
  }
}
