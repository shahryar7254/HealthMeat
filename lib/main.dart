import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(forWeb: kIsWeb),
      home: const LoginScreen(),
    );
  }
}
