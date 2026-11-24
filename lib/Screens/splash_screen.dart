import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frizalia/Screens/login_screen.dart';
import 'package:frizalia/Utils/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.rosaSuave,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.storefront, size: 90, color: AppColors.rosaFuerte),
            SizedBox(height: 20),
            Text(
              'Paletería',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.texto,
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: AppColors.rosaFuerte),
          ],
        ),
      ),
    );
  }
}
