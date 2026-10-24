import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';

class _OnboardingPage {
  final String title;
  final String eyebrow;
  final String description;
  final String image;
  final IconData icon;
  final Color accent;

  const _OnboardingPage({
    required this.title,
    required this.eyebrow,
    required this.description,
    required this.image,
    required this.icon,
    required this.accent,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      title: 'Discover Nairobi Routes',
      eyebrow: 'SMART TRANSIT NETWORK',
      description:
          'Find the fastest matatu connections across Nairobi with verified stages, clear transfers, and reliable options.',
      image: 'assets/images/onboarding_1.jpg',
      icon: Icons.alt_route_rounded,
      accent: const Color(0xFF1E88E5),
    ),
    _OnboardingPage(
      title: 'Accurate Fares & Stages',
      eyebrow: 'NO SURPRISES',
      description:
          'Compare estimated matatu fares, peak travel durations, and exact stage spots before you step out to commute.',
      image: 'assets/images/onboarding_2.jpg',
      icon: Icons.payments_rounded,
      accent: AppColors.accent,
    ),
    _OnboardingPage(
      title: 'Navigate with Confidence',
      eyebrow: 'STEP-BY-STEP GUIDANCE',
      description:
          'Get stage-by-stage transit guidance so you always know where to board, swap connections, and alight.',
      image: 'assets/images/onboarding_3.jpg',
      icon: Icons.navigation_rounded,
      accent: const Color(0xFF7C4DFF),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Avoid a blank frame the first time each image appears.
    for (final page in _pages) {
      precacheImage(AssetImage(page.image), context);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToWelcome() => context.go('/welcome');

  void _next() {
    if (_currentPage == _pages.length - 1) {
      _goToWelcome();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB);
    final textColor = isDark ? Colors.white : AppColors.textLight;
    final subColor = isDark ? Colors.white60 : AppColors.textSecondaryLight;
    final brand = isDark ? AppColors.accent : AppColors.primary;
    final isLast = _currentPage == _pages.length - 1;

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
            // ── Pages (image + content sheet) and fixed bottom controls ──
            Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      HapticFeedback.selectionClick();
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) => _buildPage(
                      _pages[index],
                      bg: bg,
                      textColor: textColor,
                      subColor: subColor,
                    ),
                  ),
                ),
                _buildControls(bg: bg, brand: brand, isDark: isDark, isLast: isLast),
              ],
            ),

            // ── Header (brand + skip), above everything for tap access ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p20, vertical: AppSizes.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _glass(
                        child: const Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_bus_rounded,
                                  size: 15, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                'ROUTEZ',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      AnimatedOpacity(
                        opacity: isLast ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: IgnorePointer(
                          ignoring: isLast,
                          child: _glass(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: _goToWelcome,
                                borderRadius:
                                    BorderRadius.circular(AppSizes.radiusFull),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 7),
                                  child: Text(
                                    'Skip',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.5,
                                    ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── One slide: photo on top, rounded content sheet overlapping it ─────────
  Widget _buildPage(
    _OnboardingPage page, {
    required Color bg,
    required Color textColor,
    required Color subColor,
  }) {
    const sheetRadius = 32.0;
    const badgeSize = 60.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageHeight = constraints.maxHeight * 0.55;
        final sheetTop = imageHeight - sheetRadius;

        return Stack(
          children: [
            // Photo
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    page.image,
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                  ),
                  // Top scrim keeps the status bar and header pills readable
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.4],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content sheet (solid surface = guaranteed text contrast)
            Positioned(
              top: sheetTop,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(sheetRadius),
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSizes.p24,
                    badgeSize / 2 + 18,
                    AppSizes.p24,
                    8,
                  ),
                  child: Column(
                    children: [
                      Text(
                        page.eyebrow,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: page.accent,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        page.title,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.6,
                          height: 1.2,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        page.description,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.55,
                          color: subColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Icon badge sitting on the sheet's top edge
            Positioned(
              top: sheetTop - badgeSize / 2,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  width: badgeSize,
                  height: badgeSize,
                  decoration: BoxDecoration(
                    color: page.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: bg, width: 5),
                    boxShadow: [
                      BoxShadow(
                        color: page.accent.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(page.icon, color: Colors.white, size: 26),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Dots + full-width primary button ──────────────────────────────────────
  Widget _buildControls({
    required Color bg,
    required Color brand,
    required bool isDark,
    required bool isLast,
  }) {
    return Container(
      color: bg,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSizes.p24, 12, AppSizes.p24, AppSizes.p24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 8,
                    width: _currentPage == index ? 28 : 8,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? brand
                          : (isDark ? Colors.white24 : Colors.black12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: brand,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isLast ? 'Get Started' : 'Next',
                          key: ValueKey<bool>(isLast),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSizes.p6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Frosted pill used by the header ───────────────────────────────────────
  Widget _glass({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(AppSizes.radiusFull),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}