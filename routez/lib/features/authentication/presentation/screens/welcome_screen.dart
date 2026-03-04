import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Icon(
                Icons.directions_bus,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: AppSizes.p24),
              Text(
                'Welcome to Routez',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Text(
                'Your ultimate Nairobi transit companion.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              PrimaryButton(
                text: 'Login',
                onPressed: () => context.push('/login'),
              ),
              const SizedBox(height: AppSizes.p16),
              PrimaryButton(
                text: 'Sign Up',
                isOutlined: true,
                onPressed: () => context.push('/signup'),
              ),
              const SizedBox(height: AppSizes.p16),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                    ),
                    child: Text(
                      'OR',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              PrimaryButton(
                text: 'Continue with Google',
                icon: const Icon(Icons.g_mobiledata, size: 32),
                isOutlined: true,
                onPressed: () {
                  // Mock Google Sign-In
                  context.go('/home');
                },
              ),
              const SizedBox(height: AppSizes.p32),
            ],
          ),
        ),
      ),
    );
  }
}
