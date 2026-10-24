import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _fullNameController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      context.go('/home');
    } else {
      final error = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.toString().replaceAll('Exception: ', '') ??
                'Registration failed. Please try again.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB);
    final textColor = isDark ? Colors.white : AppColors.textLight;
    final subColor = isDark ? Colors.white60 : AppColors.textSecondaryLight;
    final brand = isDark ? AppColors.accent : AppColors.primary;
    final fieldFill = isDark ? const Color(0xFF161C23) : Colors.white;
    final fieldBorder = isDark
        ? Colors.white.withValues(alpha: 0.10)
        : Colors.black.withValues(alpha: 0.08);

    final isLoading = ref.watch(authControllerProvider).isLoading;

    final imageHeight = mediaQuery.size.height * 0.30;
    // Content starts where the fade is almost fully opaque
    final contentTop = imageHeight * 0.74;

    OutlineInputBorder outline(Color color, {double width = 1.2}) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: color, width: width),
        );

    // One reusable labelled field so all four look identical
    Widget field({
      required String label,
      required String hint,
      required IconData icon,
      required TextEditingController controller,
      required String? Function(String?) validator,
      TextInputType? keyboardType,
      TextInputAction action = TextInputAction.next,
      Iterable<String>? autofillHints,
      bool? obscure,
      VoidCallback? onToggleObscure,
      VoidCallback? onSubmitted,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          TextFormField(
            controller: controller,
            obscureText: obscure ?? false,
            keyboardType: keyboardType,
            textInputAction: action,
            autofillHints: autofillHints,
            onFieldSubmitted: (_) => onSubmitted?.call(),
            style: TextStyle(fontSize: 14.5, color: textColor),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 13.5,
                color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
              ),
              filled: true,
              fillColor: fieldFill,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              prefixIcon: Icon(icon, size: 20, color: brand),
              suffixIcon: onToggleObscure == null
                  ? null
                  : IconButton(
                      icon: Icon(
                        (obscure ?? false)
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 20,
                        color: subColor,
                      ),
                      onPressed: onToggleObscure,
                    ),
              border: outline(fieldBorder),
              enabledBorder: outline(fieldBorder),
              focusedBorder: outline(brand, width: 1.6),
              errorBorder: outline(Theme.of(context).colorScheme.error),
              focusedErrorBorder:
                  outline(Theme.of(context).colorScheme.error, width: 1.6),
            ),
            validator: validator,
          ),
        ],
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: bg,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // ── 1. Hero image blending into the background ────────────────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/auth_hero.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  // Top scrim for the status bar and back button
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.40),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.40],
                      ),
                    ),
                  ),
                  // Bottom fade into the background colour
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          bg.withValues(alpha: 0.0),
                          bg.withValues(alpha: 0.55),
                          bg.withValues(alpha: 0.92),
                          bg,
                        ],
                        stops: const [0.40, 0.68, 0.88, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Scrollable form ─────────────────────────────────────────
            // The mask fades content out as it scrolls up into the photo, so
            // text never sits on top of the busy part of the image.
            Positioned.fill(
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [Colors.transparent, Colors.black],
                  stops: [
                    (contentTop * 0.55) / rect.height,
                    contentTop / rect.height,
                  ],
                ).createShader(rect),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    AppSizes.p24,
                    contentTop,
                    AppSizes.p24,
                    mediaQuery.padding.bottom + AppSizes.p24,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Create an Account',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            height: 1.2,
                            color: brand,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Join thousands of Nairobi commuters traveling smarter with Routez.',
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.5,
                            color: subColor,
                          ),
                        ),
                        const SizedBox(height: 24),

                        field(
                          label: 'Full Name',
                          hint: 'e.g. Brian Otieno',
                          icon: Icons.person_outline_rounded,
                          controller: _fullNameController,
                          autofillHints: const [AutofillHints.name],
                          validator: (val) => val == null || val.trim().isEmpty
                              ? 'Name is required'
                              : null,
                        ),
                        const SizedBox(height: AppSizes.p16),

                        field(
                          label: 'Email Address',
                          hint: 'e.g. commuter@nairobi.co.ke',
                          icon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          validator: (val) {
                            final v = val?.trim() ?? '';
                            if (v.isEmpty) return 'Email is required';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(v);
                            return ok ? null : 'Enter a valid email address';
                          },
                        ),
                        const SizedBox(height: AppSizes.p16),

                        field(
                          label: 'Password',
                          hint: 'Min 6 characters',
                          icon: Icons.lock_outline_rounded,
                          controller: _passwordController,
                          obscure: _obscurePassword,
                          onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          autofillHints: const [AutofillHints.newPassword],
                          validator: (val) => val == null || val.length < 6
                              ? 'Min 6 characters required'
                              : null,
                        ),
                        const SizedBox(height: AppSizes.p16),

                        field(
                          label: 'Confirm Password',
                          hint: 'Re-enter your password',
                          icon: Icons.lock_reset_rounded,
                          controller: _confirmController,
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          action: TextInputAction.done,
                          onSubmitted: _handleSignup,
                          validator: (val) => val != _passwordController.text
                              ? 'Passwords do not match'
                              : null,
                        ),
                        const SizedBox(height: 28),

                        // Sign Up button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleSignup,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(0, 56),
                              backgroundColor: brand,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  brand.withValues(alpha: 0.6),
                              disabledForegroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    AppSizes.radiusFull),
                              ),
                            ),
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Create Account',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Login footer
                        Center(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => context.pushReplacement('/login'),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              child: Text.rich(
                                TextSpan(
                                  text: 'Already have an account?  ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: subColor,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Log in',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: brand,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── 3. Floating glass back button ──────────────────────────────
            // Must be Positioned: a non-positioned child in this Stack would
            // shrink the whole Stack to the button's size.
            Positioned(
              top: 0,
              left: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16, vertical: AppSizes.p8),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_rounded,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go('/welcome');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}