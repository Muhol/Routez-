import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import 'package:routez/features/trip_history/data/models/trip_model.dart';
import 'package:routez/features/trip_history/presentation/providers/trip_history_provider.dart';

class TripHistoryScreen extends ConsumerStatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  ConsumerState<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends ConsumerState<TripHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTripDetailsBottomSheet(TripModel trip) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSizes.radiusLarge)),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Padding(
          padding: EdgeInsets.only(
            top: AppSizes.p24,
            left: AppSizes.p24,
            right: AppSizes.p24,
            bottom: AppSizes.p24 + 80,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSizes.p10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.receipt_long, color: AppColors.primary),
                      ),
                      const SizedBox(width: AppSizes.p12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trip Details',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            trip.id.substring(0, trip.id.length > 8 ? 8 : trip.id.length),
                            style: const TextStyle(
                              color: AppColors.textSecondaryLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p16),
              const Divider(),
              const SizedBox(height: AppSizes.p12),

              // Route Diagram
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1A1A1A) : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.radio_button_checked,
                            color: AppColors.primary, size: 20),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Text(
                            'From: ${trip.origin}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 9),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: 2,
                          height: 24,
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: AppColors.accent, size: 20),
                        const SizedBox(width: AppSizes.p12),
                        Expanded(
                          child: Text(
                            'To: ${trip.destination}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p16),

              // Info Breakdown Grid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailTile(context, 'Route', trip.routeName, Icons.alt_route),
                  _buildDetailTile(context, 'Duration', '${trip.durationMins} mins', Icons.timer_outlined),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailTile(context, 'Total Fare', 'KES ${trip.fare}', Icons.payments_outlined),
                  _buildDetailTile(
                    context,
                    'Payment',
                    trip.mpesaRef != null ? '${trip.paymentMethod} (${trip.mpesaRef})' : trip.paymentMethod,
                    Icons.account_balance_wallet_outlined,
                  ),
                ],
              ),

              const SizedBox(height: AppSizes.p24),

              // Repeat Trip Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push(
                      '/route-results',
                      extra: {
                        'origin': trip.origin,
                        'destination': trip.destination,
                      },
                    );
                  },
                  icon: const Icon(Icons.replay),
                  label: const Text('Repeat This Trip'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p14),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailTile(
      BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondaryLight),
          const SizedBox(width: AppSizes.p8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tripDate = DateTime(date.year, date.month, date.day);

    if (tripDate == today) return 'Today';
    if (tripDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripHistoryProvider);

    return Scaffold(
      appBar: GlassAppBar(
        title: const Text('Trip History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear History',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Trip History?'),
                  content: const Text('This will permanently delete all past trip records.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ref.read(tripHistoryControllerProvider.notifier).clearAllTrips();
                      },
                      child: const Text('Clear All', style: TextStyle(color: AppColors.error)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(AppSizes.p16),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() {
                  _searchQuery = val.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by destination or route...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondaryLight),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSizes.p16,
                  vertical: AppSizes.p12,
                ),
              ),
            ),
          ),

          Expanded(
            child: tripsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => const EmptyStateWidget(
                icon: Icons.cloud_off_outlined,
                title: 'Could Not Load History',
                message: 'Unable to reach the database. Check your connection and try again.',
              ),
              data: (trips) {
                // Filter by search query
                final filteredTrips = trips.where((t) {
                  return t.destination.toLowerCase().contains(_searchQuery) ||
                      t.origin.toLowerCase().contains(_searchQuery) ||
                      t.routeName.toLowerCase().contains(_searchQuery) ||
                      t.routeNumber.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredTrips.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.history_outlined,
                    title: _searchQuery.isNotEmpty
                        ? 'No Results'
                        : 'No Trips Yet',
                    message: _searchQuery.isNotEmpty
                        ? 'No trips match "$_searchQuery". Try a different search term.'
                        : 'Your completed trips will appear here after you finish a journey.',
                  );
                }

                // Group trips by date header
                final Map<String, List<TripModel>> grouped = {};
                for (final t in filteredTrips) {
                  final header = _formatDateHeader(t.departedAt);
                  grouped.putIfAbsent(header, () => []).add(t);
                }

                final groupKeys = grouped.keys.toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16),
                  itemCount: groupKeys.length,
                  itemBuilder: (context, groupIdx) {
                    final groupTitle = groupKeys[groupIdx];
                    final groupTrips = grouped[groupTitle]!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                          child: Text(
                            groupTitle,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                          ),
                        ),
                        ...groupTrips.map((trip) {
                          final isMpesa = trip.paymentMethod.toLowerCase().contains('mpesa');
                          final timeStr =
                              '${trip.departedAt.hour.toString().padLeft(2, '0')}:${trip.departedAt.minute.toString().padLeft(2, '0')}';

                          return Card(
                            margin: const EdgeInsets.only(bottom: AppSizes.p12),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(AppSizes.p12),
                              leading: CircleAvatar(
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                child: const Icon(
                                  Icons.directions_bus,
                                  color: AppColors.primary,
                                ),
                              ),
                              title: Text(
                                trip.destination,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${trip.origin} • ${trip.routeNumber}\n$timeStr • ${trip.durationMins} mins',
                                style: const TextStyle(fontSize: 12),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'KES ${trip.fare}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Icon(
                                    isMpesa ? Icons.smartphone : Icons.payments,
                                    size: 16,
                                    color: AppColors.textSecondaryLight,
                                  ),
                                ],
                              ),
                              onTap: () => _showTripDetailsBottomSheet(trip),
                            ),
                          );
                        }),
                      ],
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
}
