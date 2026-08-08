import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/route_card.dart';

class RouteResultsScreen extends StatefulWidget {
  const RouteResultsScreen({super.key});

  @override
  State<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends State<RouteResultsScreen> {
  String _selectedFilter = 'All';
  final Set<String> _bookmarkedRoutes = {};

  final List<Map<String, dynamic>> _routes = [
    {
      'id': '23',
      'routeNumber': '23',
      'estimatedTime': '45 mins',
      'fare': 'KES 60',
      'fareValue': 60,
      'timeMinutes': 45,
      'walkMinutes': 5,
      'transitMinutes': 40,
      'steps': [
        'Walk to Pipeline Stage (5 mins)',
        'Board Matatu 23 towards Westlands',
        'Alight at Westlands Stage',
      ],
    },
    {
      'id': '46',
      'routeNumber': '46',
      'estimatedTime': '55 mins',
      'fare': 'KES 50',
      'fareValue': 50,
      'timeMinutes': 55,
      'walkMinutes': 10,
      'transitMinutes': 45,
      'steps': [
        'Walk to Taj Mall Stage (10 mins)',
        'Board Matatu 46 towards Westlands',
        'Alight at Westlands Stage',
      ],
    },
    {
      'id': '110',
      'routeNumber': '110 Express',
      'estimatedTime': '35 mins',
      'fare': 'KES 80',
      'fareValue': 80,
      'timeMinutes': 35,
      'walkMinutes': 3,
      'transitMinutes': 32,
      'steps': [
        'Walk to Pipeline Express Stage (3 mins)',
        'Board Express Matatu 110',
        'Alight at Westlands Flyover Stage',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedRoutes = List.from(_routes);
    if (_selectedFilter == 'Fastest') {
      displayedRoutes.sort((a, b) => (a['timeMinutes'] as int).compareTo(b['timeMinutes'] as int));
    } else if (_selectedFilter == 'Cheapest') {
      displayedRoutes.sort((a, b) => (a['fareValue'] as int).compareTo(b['fareValue'] as int));
    } else if (_selectedFilter == 'Least Walking') {
      displayedRoutes.sort((a, b) => (a['walkMinutes'] as int).compareTo(b['walkMinutes'] as int));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Routes'), elevation: 0),
      body: Column(
        children: [
          // Filter & Sort Pills
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
              children: [
                _buildFilterChip('All'),
                _buildFilterChip('Fastest'),
                _buildFilterChip('Cheapest'),
                _buildFilterChip('Least Walking'),
              ],
            ),
          ),
          // const Divider(height: 1),
          // Route Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: displayedRoutes.length,
              itemBuilder: (context, index) {
                final r = displayedRoutes[index];
                final isBookmarked = _bookmarkedRoutes.contains(r['id']);

                return RouteCard(
                  routeNumber: r['routeNumber'],
                  estimatedTime: r['estimatedTime'],
                  fare: r['fare'],
                  walkDurationMinutes: r['walkMinutes'],
                  transitDurationMinutes: r['transitMinutes'],
                  steps: List<String>.from(r['steps']),
                  isBookmarked: isBookmarked,
                  onBookmarkTap: () {
                    setState(() {
                      if (isBookmarked) {
                        _bookmarkedRoutes.remove(r['id']);
                      } else {
                        _bookmarkedRoutes.add(r['id']);
                      }
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isBookmarked
                              ? 'Route ${r['routeNumber']} removed from saved'
                              : 'Route ${r['routeNumber']} saved!',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onTap: () => context.push('/route-detail', extra: r),
                  onStartTrip: () => context.push('/active-trip'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.p8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(
          color: isSelected
              ? Colors.white
              : (isDark ? AppColors.textDark : AppColors.textLight),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() => _selectedFilter = label);
          }
        },
      ),
    );
  }
}
