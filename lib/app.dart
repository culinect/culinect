import 'package:flutter/material.dart';
import 'auth/auth_gate.dart';
import 'theme/theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({required Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CuliNect',
      theme: AppTheme.lightTheme, // Apply the light theme
      darkTheme: AppTheme.darkTheme, // Apply the dark theme
      home: const AuthGate(),
    );
  }
}
