import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitted = false;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.p24),
        child: _isSubmitted ? _buildSuccess() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter your email address and we will send you a link to reset your password.',
          ),
          const SizedBox(height: AppSizes.p24),
          CustomTextField(
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (val) =>
                val == null || val.isEmpty ? 'Email is required' : null,
          ),
          const SizedBox(height: AppSizes.p32),
          PrimaryButton(
            text: 'Send Reset Link',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _isSubmitted = true);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: AppSizes.p24),
          Text('Link Sent!', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: AppSizes.p8),
          const Text(
            'Please check your email to reset your password.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
