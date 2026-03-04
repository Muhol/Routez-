import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/route_card.dart';

class RouteResultsScreen extends StatelessWidget {
  const RouteResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Suggested Routes'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          RouteCard(
            routeNumber: '23',
            estimatedTime: '45 mins',
            fare: 'KES 60',
            walkDurationMinutes: 5,
            transitDurationMinutes: 40,
            steps: const [
              'Walk to Pipeline Stage (5 mins)',
              'Board Matatu 23 towards Westlands',
              'Alight at Westlands Stage',
            ],
            onStartTrip: () => context.push('/active-trip'),
          ),
          RouteCard(
            routeNumber: '46',
            estimatedTime: '55 mins',
            fare: 'KES 50',
            walkDurationMinutes: 10,
            transitDurationMinutes: 45,
            steps: const [
              'Walk to Taj Mall Stage (10 mins)',
              'Board Matatu 46 towards Westlands',
              'Alight at Westlands Stage',
            ],
            onStartTrip: () => context.push('/active-trip'),
          ),
        ],
      ),
    );
  }
}
