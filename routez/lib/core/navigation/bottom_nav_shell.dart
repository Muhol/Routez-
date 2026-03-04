import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavShell extends StatelessWidget {
  final Widget child;

  const BottomNavShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: child, bottomNavigationBar: _buildBottomNav(context));
  }

  Widget _buildBottomNav(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    int currentIndex = 0;
    if (location.startsWith('/saved')) currentIndex = 1;
    if (location.startsWith('/trips')) currentIndex = 2;
    if (location.startsWith('/profile')) currentIndex = 3;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/saved');
            break;
          case 2:
            context.go('/trips');
            break;
          case 3:
            context.go('/profile');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bookmark_border),
          activeIcon: Icon(Icons.bookmark),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          activeIcon: Icon(Icons.history),
          label: 'Trips',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
