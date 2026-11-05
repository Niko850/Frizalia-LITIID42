import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frizalia/Screens/login_screen.dart';

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
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        255,
        236,
        178,
        249,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.storefront,
              size: 90,
              color: Color.fromARGB(
                255,
                0,
                0,
                0,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Paletería',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(
                  255,
                  0,
                  0,
                  0,
                ),
              ),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(
              color: Color.fromARGB(
                255,
                0,
                0,
                0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}