import 'package:flutter/material.dart';
import 'package:w51/app/routes/app_shell.dart';
import 'package:w51/app/theme/app_theme.dart';
import 'package:w51/features/auth/presentation/login_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MyDream',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: _isLoggedIn
          ? const AppShell()
          : LoginPage(
              onLoginSuccess: () => setState(() => _isLoggedIn = true),
            ),
    );
  }
}
