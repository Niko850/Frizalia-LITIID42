import 'package:flutter/material.dart';
import 'package:frizalia/Screens/login_screen.dart';

void main() {
  runApp(const FrizaliaApp());
}

class FrizaliaApp extends StatelessWidget {
  const FrizaliaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Frizalia',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDFBF7),
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB6A4F2)),
      ),
      home: const LoginScreen(),
    );
  }
}
