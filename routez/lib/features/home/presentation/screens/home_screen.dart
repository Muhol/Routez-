import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            color: AppColors.backgroundLight,
            width: double.infinity,
            height: double.infinity,
            child: const Center(
              child: Icon(Icons.map, size: 120, color: AppColors.dividerLight),
            ),
          ),

          // Top Search Bar Area
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => context.push('/search'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p16,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.search,
                            color: AppColors.textSecondaryLight,
                          ),
                          const SizedBox(width: AppSizes.p12),
                          Text(
                            'Where are you going?',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSizes.p16),
                  // Quick Actions
                  Row(
                    children: [
                      _buildQuickAction(context, Icons.work, 'Work'),
                      const SizedBox(width: AppSizes.p12),
                      _buildQuickAction(context, Icons.home, 'Home'),
                      const SizedBox(width: AppSizes.p12),
                      _buildQuickAction(context, Icons.star, 'Popular'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Floating Action Button (Location)
          Positioned(
            right: AppSizes.p16,
            bottom: AppSizes.p16,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.my_location),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.15,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(AppSizes.radiusLarge),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(AppSizes.p16),
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSizes.p16),
                        decoration: BoxDecoration(
                          color: AppColors.dividerLight,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Nearby Stages',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: AppSizes.p8),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.directions_bus,
                        color: AppColors.primary,
                      ),
                      title: const Text('Pipeline Stage'),
                      subtitle: const Text('2 mins walk'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.directions_bus,
                        color: AppColors.primary,
                      ),
                      title: const Text('Taj Mall Stage'),
                      subtitle: const Text('5 mins walk'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(),
                    const SizedBox(height: AppSizes.p8),
                    Text(
                      'Suggested Routes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(
                        Icons.route,
                        color: AppColors.primary,
                      ),
                      title: const Text('Westlands (Route 23)'),
                      subtitle: const Text('ETA: 45 mins • KES 80'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/route-results'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSizes.p12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: AppSizes.p4),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
