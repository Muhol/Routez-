import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class RouteDetailScreen extends StatelessWidget {
  final Map<String, dynamic>? routeData;

  const RouteDetailScreen({super.key, this.routeData});

  @override
  Widget build(BuildContext context) {
    final routeNumber = routeData?['routeNumber'] ?? '23';
    final estimatedTime = routeData?['estimatedTime'] ?? '45 mins';
    final fare = routeData?['fare'] ?? 'KES 60';
    final walkMinutes = routeData?['walkMinutes'] ?? 5;
    final transitMinutes = routeData?['transitMinutes'] ?? 40;

    return Scaffold(
      appBar: AppBar(
        title: Text('Route $routeNumber Details'),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p80 + 20,
            ),
            children: [
              // Summary Banner Card
              Container(
                padding: const EdgeInsets.all(AppSizes.p20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSizes.p12,
                            vertical: AppSizes.p6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                          ),
                          child: Text(
                            'Route $routeNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          fare,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p16),
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, color: Colors.white70, size: 20),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          'Total Time: $estimatedTime',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.p8),
                    Row(
                      children: [
                        const Icon(Icons.directions_walk, color: Colors.white70, size: 20),
                        const SizedBox(width: AppSizes.p8),
                        Text(
                          '$walkMinutes min walk  •  $transitMinutes min Matatu',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p20),

              // Map Preview Container
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.dividerLight),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map, size: 60, color: AppColors.dividerLight),
                          SizedBox(height: AppSizes.p8),
                          Text(
                            'Route Map Path Preview',
                            style: TextStyle(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: FloatingActionButton.small(
                        onPressed: () {},
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        child: const Icon(Icons.fullscreen),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              // Step Timeline Header
              Text(
                'Step-by-Step Guidance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Segment 1: Walk to Stage
              _buildTimelineStep(
                context,
                icon: Icons.directions_walk,
                iconColor: AppColors.primary,
                title: 'Walk to Stage',
                subtitle: 'Pipeline Stage (5 mins walk)',
                description: 'Head North towards Outering Road, cross safely at the pedestrian walkway.',
                isFirst: true,
              ),

              // Segment 2: Board Matatu
              _buildTimelineStep(
                context,
                icon: Icons.directions_bus,
                iconColor: AppColors.accent,
                title: 'Board Matatu $routeNumber',
                subtitle: 'Pipeline Stage → Westlands Stage ($transitMinutes mins)',
                description: 'Board Matatu $routeNumber. Expected fare: $fare. Prepare cash or M-Pesa.',
              ),

              // Segment 3: Alight
              _buildTimelineStep(
                context,
                icon: Icons.location_on,
                iconColor: AppColors.error,
                title: 'Alight at Destination Stage',
                subtitle: 'Westlands Stage',
                description: 'Alight near Westlands Roundabout. Walk 2 mins to final destination.',
                isLast: true,
              ),

              const SizedBox(height: AppSizes.p16),

              // Stage Tips Card
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppColors.warning),
                    SizedBox(width: AppSizes.p12),
                    Expanded(
                      child: Text(
                        'Matatus operate every 3-5 mins from Pipeline Stage. Confirm destination sign on windshield before boarding.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Sticky Start Trip Bottom Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(AppSizes.p16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: PrimaryButton(
                text: 'Start Trip Now',
                onPressed: () => context.push('/active-trip'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: AppColors.dividerLight,
              ),
          ],
        ),
        const SizedBox(width: AppSizes.p16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSizes.p20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondaryLight,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: AppSizes.p4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
