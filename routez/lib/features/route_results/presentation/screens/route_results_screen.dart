import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/empty_state_widget.dart';
import 'package:routez/features/search/presentation/providers/search_provider.dart';
import 'package:routez/features/search/data/models/journey_leg_model.dart';

class RouteResultsScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? searchArgs;

  const RouteResultsScreen({super.key, this.searchArgs});

  @override
  ConsumerState<RouteResultsScreen> createState() => _RouteResultsScreenState();
}

class _RouteResultsScreenState extends ConsumerState<RouteResultsScreen> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? extra = widget.searchArgs;
    if (extra == null) {
      try {
        extra = GoRouterState.of(context).extra as Map<String, dynamic>?;
      } catch (_) {}
    }

    final origin = extra?['origin'] as String? ?? 'Pipeline Stage';
    final destination = extra?['destination'] as String? ?? 'Westlands Stage';

    final searchParams = RouteSearchQuery(origin: origin, destination: destination);
    final journeysAsync = ref.watch(journeySearchResultsProvider(searchParams));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Suggested Journey Options', style: TextStyle(fontSize: 16)),
            Text(
              '$origin → $destination',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        elevation: 0,
      ),
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

          Expanded(
            child: journeysAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, __) => const EmptyStateWidget(
                icon: Icons.cloud_off_outlined,
                title: 'Could Not Load Routes',
                message: 'Unable to compute transit paths. Check database connection.',
              ),
              data: (rawJourneys) {
                if (rawJourneys.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.directions_bus_outlined,
                    title: 'No Direct Paths Found',
                    message: 'We couldn\'t find a route between these stages within 3 matatu transfers.',
                  );
                }

                // Apply user filter / re-ordering
                final journeys = List<JourneyOption>.from(rawJourneys);
                if (_selectedFilter == 'Cheapest') {
                  journeys.sort((a, b) => a.totalCheapestFare.compareTo(b.totalCheapestFare));
                } else if (_selectedFilter == 'Fastest') {
                  journeys.sort((a, b) => a.totalMinutes.compareTo(b.totalMinutes));
                } else if (_selectedFilter == 'Least Walking') {
                  journeys.sort((a, b) {
                    final walkMinsA = a.walkLegs.fold(0, (sum, l) => sum + l.durationMinutes);
                    final walkMinsB = b.walkLegs.fold(0, (sum, l) => sum + l.durationMinutes);
                    return walkMinsA.compareTo(walkMinsB);
                  });
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSizes.p16),
                  itemCount: journeys.length,
                  itemBuilder: (context, index) {
                    final journey = journeys[index];
                    final matatuLegs = journey.matatuLegs;
                    final routeSummary = matatuLegs
                        .map((l) => 'Route ${l.routeNumber ?? '?'}')
                        .join(' → ');

                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSizes.p16),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSizes.p16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Matatu Count Badge & Total Fare
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.p10,
                                    vertical: AppSizes.p4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                  child: Text(
                                    journey.matatuCountLabel,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                Text(
                                  'From KES ${journey.totalCheapestFare}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p12),

                            // Route path summary & duration
                            Row(
                              children: [
                                const Icon(Icons.alt_route, color: AppColors.accent, size: 20),
                                const SizedBox(width: AppSizes.p8),
                                Expanded(
                                  child: Text(
                                    routeSummary,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Text(
                                  '~${journey.totalMinutes} mins',
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryLight,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSizes.p12),

                            // Legs overview chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: journey.legs.map((leg) {
                                if (leg.isWalk) {
                                  return Chip(
                                    avatar: const Icon(Icons.directions_walk, size: 14),
                                    label: Text('Walk ${leg.durationMinutes}m'),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  );
                                } else {
                                  return Chip(
                                    avatar: const Icon(Icons.directions_bus, size: 14, color: AppColors.primary),
                                    label: Text('Route ${leg.routeNumber} (${leg.fromStage.name} → ${leg.toStage.name})'),
                                    padding: EdgeInsets.zero,
                                    visualDensity: VisualDensity.compact,
                                  );
                                }
                              }).toList(),
                            ),
                            const SizedBox(height: AppSizes.p12),
                            const Divider(),

                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton.icon(
                                  onPressed: () {
                                    context.push('/route-detail', extra: {
                                      'journey': journey,
                                      'origin': origin,
                                      'destination': destination,
                                    });
                                  },
                                  icon: const Icon(Icons.info_outline, size: 16),
                                  label: const Text('View Path', style: TextStyle(fontSize: 13)),
                                ),
                                const SizedBox(width: AppSizes.p8),
                                ElevatedButton(
                                  onPressed: () => context.push('/active-trip'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSizes.p14,
                                      vertical: AppSizes.p8,
                                    ),
                                  ),
                                  child: const Text('Start Trip', style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

