import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Exelbid.setLogLevel(LogLevel.debug);
  runApp(const ExelbidDemoApp());
}

class ExelbidDemoApp extends StatelessWidget {
  const ExelbidDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ExelBid Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF0A84FF),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorSchemeSeed: const Color(0xFF0A84FF),
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
