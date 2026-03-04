import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/welcome_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/saved_routes/presentation/screens/saved_routes_screen.dart';
import '../../features/trip_history/presentation/screens/trip_history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/route_results/presentation/screens/route_results_screen.dart';
import '../../features/active_trip/presentation/screens/active_trip_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/route-results',
      builder: (context, state) => const RouteResultsScreen(),
    ),
    GoRoute(
      path: '/active-trip',
      builder: (context, state) => const ActiveTripScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return BottomNavShell(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/saved',
          builder: (context, state) => const SavedRoutesScreen(),
        ),
        GoRoute(
          path: '/trips',
          builder: (context, state) => const TripHistoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
