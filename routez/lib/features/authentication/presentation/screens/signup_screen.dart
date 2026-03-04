import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create an Account',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p32),
              CustomTextField(
                label: 'Full Name',
                hint: 'Enter your full name',
                prefixIcon: const Icon(Icons.person_outline),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Name is required' : null,
              ),
              const SizedBox(height: AppSizes.p16),
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
                hint: 'Create a password',
                controller: _passwordController,
                isPassword: _obscurePassword,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (val) => val != null && val.length < 6
                    ? 'Min 6 characters required'
                    : null,
              ),
              const SizedBox(height: AppSizes.p16),
              CustomTextField(
                label: 'Confirm Password',
                hint: 'Confirm your password',
                isPassword: _obscureConfirm,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (val) => val != _passwordController.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: AppSizes.p32),
              PrimaryButton(
                text: 'Sign Up',
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
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () => context.pushReplacement('/login'),
                    child: const Text('Login'),
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
