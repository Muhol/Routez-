import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/saved_routes/presentation/screens/saved_routes_screen.dart';
import '../../features/trip_history/presentation/screens/trip_history_screen.dart';

/// Shell with 3 separated floating nav pills + horizontal PageView swiping between pages.
class BottomNavShell extends StatefulWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  @override
  State<BottomNavShell> createState() => _BottomNavShellState();
}

class _BottomNavShellState extends State<BottomNavShell> {
  late final PageController _pageController;

  static const _navItems = [
    _NavItemData(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
      path: '/home',
    ),
    _NavItemData(
      icon: Icons.bookmark_outline_rounded,
      activeIcon: Icons.bookmark_rounded,
      label: 'Saved',
      path: '/saved',
    ),
    _NavItemData(
      icon: Icons.history_rounded,
      activeIcon: Icons.history_toggle_off_rounded,
      label: 'Trips',
      path: '/trips',
    ),
  ];

  int _currentIndex = 0;
  bool _isAnimatingPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final location = GoRouterState.of(context).uri.path;
    int newIndex = 0;
    if (location.startsWith('/saved')) newIndex = 1;
    if (location.startsWith('/trips')) newIndex = 2;
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      if (_pageController.hasClients && !_isAnimatingPage) {
        _pageController.jumpToPage(newIndex);
      }
    }
  }

  void _onPageChanged(int index) {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      context.go(_navItems[index].path);
    }
  }

  void _onNavTap(int index) async {
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
      _isAnimatingPage = true;
      if (_pageController.hasClients) {
        await _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
      _isAnimatingPage = false;
      if (mounted) {
        context.go(_navItems[index].path);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: const [
          HomeScreen(),
          SavedRoutesScreen(),
          TripHistoryScreen(),
        ],
      ),
      bottomNavigationBar: _buildFloatingNavPills(context),
    );
  }

  Widget _buildFloatingNavPills(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassBg = isDark
        ? const Color(0xCC1A1F26)
        : const Color(0xEAFFFFFF);
    final glassBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.black.withValues(alpha: 0.08);
    final activePill = isDark
        ? AppColors.primary.withValues(alpha: 0.22)
        : AppColors.primary.withValues(alpha: 0.12);
    final activeColor = isDark ? AppColors.accent : AppColors.primary;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.p20,
        0,
        AppSizes.p20,
        AppSizes.p20 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = index == _currentIndex;

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 0 : AppSizes.p12,
            ),
            child: GestureDetector(
              onTap: () => _onNavTap(index),
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSelected ? AppSizes.p20 : AppSizes.p16,
                      vertical: AppSizes.p12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? activePill : glassBg,
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                      border: Border.all(
                        color: isSelected ? activeColor.withValues(alpha: 0.45) : glassBorder,
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.40 : 0.08),
                          blurRadius: 18,
                          spreadRadius: 1,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedScale(
                          scale: isSelected ? 1.12 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isSelected ? item.activeIcon : item.icon,
                            color: isSelected ? activeColor : inactiveColor,
                            size: 22,
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: AppSizes.p8),
                          AnimatedOpacity(
                            opacity: isSelected ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              item.label,
                              style: TextStyle(
                                color: activeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
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
