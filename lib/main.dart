import 'package:flutter/material.dart';
import 'package:frizalia/Screens/splash_screen.dart';
import 'package:frizalia/Utils/app_colors.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.rosaFuerte),
      ),
      home: const SplashScreen(),
    );
  }
}
