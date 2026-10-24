import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB);
    final textColor = isDark ? Colors.white : AppColors.textLight;
    final subColor = isDark ? Colors.white60 : AppColors.textSecondaryLight;
    final brand = isDark ? AppColors.accent : AppColors.primary;
    final border = isDark ? Colors.white24 : AppColors.dividerLight;

    const sheetRadius = 32.0;
    final screenHeight = mediaQuery.size.height;
    final imageHeight = screenHeight * 0.42;
    // The card overlaps the bottom of the photo by its corner radius
    final sheetTop = imageHeight - sheetRadius;

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
            // ── 1. Hero image (fixed, extends behind the status bar) ───────
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/welcome.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  // Top scrim for the status bar
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.40),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                        stops: const [0.0, 0.35],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 2. Rounded content card: scrolls up over the image ─────────
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: sheetTop),
                    Container(
                      width: double.infinity,
                      constraints:
                          BoxConstraints(minHeight: screenHeight - sheetTop),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(sheetRadius),
                        ),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        AppSizes.p24,
                        12,
                        AppSizes.p24,
                        mediaQuery.padding.bottom + AppSizes.p24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Brand logo

                          const SizedBox(height: 16),

                          // Headline + description
                          Text(
                            'Move Smarter Across Nairobi',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              height: 1.2,
                              color: brand,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 5),
                          Text(
                            'Verified matatu stages, transparent fare ranges, and reliable step-by-step connections throughout the city.',
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.55,
                              color: subColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 5),

                          // Feature chips
                          const SizedBox(height: 16),

                          // Primary action
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () => context.push('/login'),
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                                backgroundColor: brand,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusFull),
                                ),
                              ),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Secondary action
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => context.push('/signup'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                                foregroundColor: textColor,
                                side: BorderSide(color: border, width: 1.2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusFull),
                                ),
                              ),
                              child: const Text(
                                'Create an Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white12
                                      : AppColors.dividerLight,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.p16),
                                child: Text(
                                  'OR',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.8,
                                    color: subColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: isDark
                                      ? Colors.white12
                                      : AppColors.dividerLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Continue with Google
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              onPressed: () => context.go('/home'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 56),
                                foregroundColor: textColor,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white12
                                      : AppColors.dividerLight,
                                  width: 1.2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSizes.radiusFull),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: isDark
                                          ? Colors.white10
                                          : Colors.black
                                              .withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.g_mobiledata,
                                        size: 22),
                                  ),
                                  const SizedBox(width: AppSizes.p10),
                                  const Text(
                                    'Continue with Google',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}