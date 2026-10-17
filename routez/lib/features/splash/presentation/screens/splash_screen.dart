import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: Center(
        child: Image.asset(
          isDark ? 'assets/images/logo-dark.png' : 'assets/images/logo.png',
          width: 300,
        ),
      ),
    );
  }
}
