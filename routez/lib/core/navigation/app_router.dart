import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'bottom_nav_shell.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/authentication/presentation/screens/welcome_screen.dart';
import '../../features/authentication/presentation/screens/login_screen.dart';
import '../../features/authentication/presentation/screens/signup_screen.dart';
import '../../features/authentication/presentation/screens/forgot_password_screen.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/saved_routes/presentation/screens/saved_routes_screen.dart';
import '../../features/saved_routes/presentation/screens/add_saved_location_screen.dart';
import '../../features/trip_history/presentation/screens/trip_history_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/route_results/presentation/screens/route_results_screen.dart';
import '../../features/route_results/presentation/screens/route_detail_screen.dart';
import '../../features/active_trip/presentation/screens/active_trip_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

/// Provider for GoRouter that observes Auth State changes for dynamic navigation guards
final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoading = authState.isLoading;
      final user = authState.asData?.value;
      final loc = state.matchedLocation;

      // While auth is loading AND on splash, stay on splash
      if (isLoading && loc == '/') return null;

      // Routes that are ONLY for unauthenticated users
      const guestOnlyRoutes = {
        '/onboarding',
        '/welcome',
        '/login',
        '/signup',
        '/forgot-password',
      };

      final isGuestOnly = guestOnlyRoutes.contains(loc);

      if (user != null) {
        // Logged-in user on guest route or splash route -> redirect to /home
        if (isGuestOnly || loc == '/') return '/home';
        return null;
      } else {
        // Guest user on protected route -> redirect to /welcome
        if (!isGuestOnly && loc != '/' && loc != '/onboarding') return '/welcome';
        // Guest user on splash route when auth is done loading -> redirect to /onboarding
        if (loc == '/') return '/onboarding';
        return null;
      }
    },
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
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
      GoRoute(
        path: '/route-results',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RouteResultsScreen(searchArgs: extra);
        },
      ),
      GoRoute(
        path: '/route-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return RouteDetailScreen(routeData: extra);
        },
      ),
      GoRoute(
        path: '/active-trip',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ActiveTripScreen(tripData: extra);
        },
      ),
      GoRoute(
        path: '/add-saved-location',
        builder: (context, state) => const AddSavedLocationScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return BottomNavShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/saved',
            builder: (context, state) => const SavedRoutesScreen(),
          ),
          GoRoute(
            path: '/trips',
            builder: (context, state) => const TripHistoryScreen(),
          ),
        ],
      ),
    ],
  );
});

/// Fallback static router instance for direct legacy usage if needed
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
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(path: '/search', builder: (context, state) => const SearchScreen()),
    GoRoute(
      path: '/route-results',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RouteResultsScreen(searchArgs: extra);
      },
    ),
    GoRoute(
      path: '/route-detail',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RouteDetailScreen(routeData: extra);
      },
    ),
    GoRoute(
      path: '/active-trip',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ActiveTripScreen(tripData: extra);
      },
    ),
    GoRoute(
      path: '/add-saved-location',
      builder: (context, state) => const AddSavedLocationScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
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
      ],
    ),
  ],
);
