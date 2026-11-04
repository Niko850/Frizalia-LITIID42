
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FrizaliaApp());
}

class FrizaliaApp extends StatelessWidget {
  const FrizaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frizalia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const LoginScreen(),
    );
  }
}
