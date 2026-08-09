import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class BottomNavShell extends StatelessWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: _buildGlassBottomNav(context),
    );
  }

  Widget _buildGlassBottomNav(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int currentIndex = 0;
    if (location.startsWith('/saved')) currentIndex = 1;
    if (location.startsWith('/trips')) currentIndex = 2;
    if (location.startsWith('/profile')) currentIndex = 3;

    final navItems = [
      const _NavItemData(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        path: '/home',
      ),
      const _NavItemData(
        icon: Icons.bookmark_border,
        activeIcon: Icons.bookmark,
        label: 'Saved',
        path: '/saved',
      ),
      const _NavItemData(
        icon: Icons.history_outlined,
        activeIcon: Icons.history,
        label: 'Trips',
        path: '/trips',
      ),
      const _NavItemData(
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: 'Profile',
        path: '/profile',
      ),
    ];

    final glassBg =
        isDark ? AppColors.glassBackgroundDark : AppColors.glassBackgroundLight;
    final glassBorder =
        isDark ? AppColors.glassBorderDark : AppColors.glassBorderLight;
    final activePill =
        isDark ? AppColors.glassPillDark : AppColors.glassPillLight;
    final activeColor = isDark ? AppColors.accent : AppColors.primary;
    final inactiveColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSizes.p16,
        0,
        AppSizes.p16,
        AppSizes.p20,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular + 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 24,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusCircular + 8),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.p8,
              vertical: AppSizes.p8,
            ),
            decoration: BoxDecoration(
              color: glassBg,
              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
              border: Border.all(color: glassBorder, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = index == currentIndex;

                return GestureDetector(
                  onTap: () {
                    if (currentIndex != index) {
                      context.go(item.path);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p14,
                      vertical: AppSizes.p10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? activePill : Colors.transparent,
                      borderRadius: BorderRadius.circular(
                        AppSizes.radiusMedium + 4,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.15 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? activeColor : inactiveColor,
                            size: 22,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: AppSizes.p6),
                          AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: activeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
