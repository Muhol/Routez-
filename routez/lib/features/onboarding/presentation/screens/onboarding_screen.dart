import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/app_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Discover Routes',
      'description': 'Find the fastest matatu routes across Nairobi with ease.',
      'icon': 'map',
    },
    {
      'title': 'Save Time & Fare',
      'description':
          'Compare different route options and estimated fares before you travel.',
      'icon': 'wallet',
    },
    {
      'title': 'Travel Smart & Safe',
      'description': 'Get step-by-step guidance to your destination.',
      'icon': 'shield',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => context.go('/welcome'),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  IconData iconData = Icons.map;
                  if (page['icon'] == 'wallet') {
                    iconData = Icons.account_balance_wallet;
                  }
                  if (page['icon'] == 'shield') {
                    iconData = Icons.shield_outlined;
                  }

                  return Padding(
                    padding: const EdgeInsets.all(AppSizes.p32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          iconData,
                          size: 120,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: AppSizes.p48),
                        Text(
                          page['title']!,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSizes.p16),
                        Text(
                          page['description']!,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.p24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => _buildDot(index),
                    ),
                  ),
                  SizedBox(
                    width: 140,
                    child: PrimaryButton(
                      text: _currentPage == _pages.length - 1
                          ? 'Get Started'
                          : 'Next',
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          context.go('/welcome');
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
