import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p32),
              CustomTextField(
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Email is required' : null,
              ),
              const SizedBox(height: AppSizes.p16),
              CustomTextField(
                label: 'Password',
                hint: 'Enter your password',
                isPassword: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Password is required' : null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(
                    '/forgot-password',
                  ), // Ensure it exists in GoRouter
                  child: const Text('Forgot Password?'),
                ),
              ),
              const SizedBox(height: AppSizes.p24),
              PrimaryButton(
                text: 'Login',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.go('/home');
                  }
                },
              ),
              const SizedBox(height: AppSizes.p24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () => context.pushReplacement('/signup'),
                    child: const Text('Sign up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
