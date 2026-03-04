import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';
import '../constants/app_colors.dart';

class RouteCard extends StatelessWidget {
  final String routeNumber;
  final String estimatedTime;
  final String fare;
  final int walkDurationMinutes;
  final int transitDurationMinutes;
  final List<String> steps;
  final VoidCallback onStartTrip;

  const RouteCard({
    super.key,
    required this.routeNumber,
    required this.estimatedTime,
    required this.fare,
    required this.walkDurationMinutes,
    required this.transitDurationMinutes,
    required this.steps,
    required this.onStartTrip,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.p16),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSizes.p16,
            vertical: AppSizes.p8,
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p12,
                  vertical: AppSizes.p4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  routeNumber,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.p12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      estimatedTime,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      fare,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: AppSizes.p8),
            child: Text(
              '🚶 $walkDurationMinutes min walk • 🚌 $transitDurationMinutes min matatu',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...steps.map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.p8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.circle,
                              size: 8,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSizes.p12),
                          Expanded(child: Text(step)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onStartTrip,
                      child: const Text('Start Trip'),
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
}
