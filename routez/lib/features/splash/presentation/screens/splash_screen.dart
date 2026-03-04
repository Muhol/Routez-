import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.directions_bus,
              size: 80,
              color: Colors.white,
            ), // Logo placeholder
            const SizedBox(height: AppSizes.p16),
            Text(
              'Routez',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: AppSizes.p64),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
