import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class ActiveTripScreen extends StatelessWidget {
  const ActiveTripScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColors.backgroundLight,
            child: const Center(
              child: Icon(Icons.map, size: 100, color: AppColors.dividerLight),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.p16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSizes.p12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSizes.p16,
                        vertical: AppSizes.p12,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusMedium,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'To Westlands',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white70),
                          ),
                          Text(
                            'ETA: 10:45 AM (40 mins)',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(AppSizes.p16),
              padding: const EdgeInsets.all(AppSizes.p24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.p16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Walk to Pipeline Stage',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppSizes.p4),
                            Text(
                              '5 mins remaining',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSizes.p24),
                  const LinearProgressIndicator(value: 0.1),
                  const SizedBox(height: AppSizes.p24),
                  PrimaryButton(
                    text: 'End Trip',
                    isOutlined: true,
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
