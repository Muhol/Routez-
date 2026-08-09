import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
// import '../../../../core/widgets/glass_app_bar.dart';

class TripHistoryScreen extends StatefulWidget {
  const TripHistoryScreen({super.key});

  @override
  State<TripHistoryScreen> createState() => _TripHistoryScreenState();
}

class _TripHistoryScreenState extends State<TripHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _allTrips = [
    {
      'date': 'Today',
      'trips': [
        {
          'id': 'TRIP-101',
          'destination': 'Westlands Stage',
          'origin': 'Pipeline Stage',
          'fare': 'KES 80',
          'duration': '45 mins',
          'time': '10:00 AM',
          'route': 'Route 23 Express',
          'payment': 'M-Pesa (Ref: QX78291)',
          'status': 'Completed',
        },
      ],
    },
    {
      'date': 'Yesterday',
      'trips': [
        {
          'id': 'TRIP-102',
          'destination': 'CBD, Kencom Stage',
          'origin': 'Taj Mall Stage',
          'fare': 'KES 50',
          'duration': '30 mins',
          'time': '08:30 AM',
          'route': 'Route 33',
          'payment': 'M-Pesa (Ref: QX78110)',
          'status': 'Completed',
        },
        {
          'id': 'TRIP-103',
          'destination': 'Pipeline Stage',
          'origin': 'Kencom Stage',
          'fare': 'KES 100',
          'duration': '55 mins',
          'time': '05:45 PM',
          'route': 'Route 110 Express',
          'payment': 'Cash',
          'status': 'Completed',
        },
      ],
    },
    {
      'date': 'Last Week',
      'trips': [
        {
          'id': 'TRIP-104',
          'destination': 'Kilimani, Yaya Center',
          'origin': 'Westlands Stage',
          'fare': 'KES 70',
          'duration': '35 mins',
          'time': '02:15 PM',
          'route': 'Route 46',
          'payment': 'M-Pesa (Ref: QX77992)',
          'status': 'Completed',
        },
      ],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTripDetailsBottomSheet(Map<String, dynamic> trip) {
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
            bottom: AppSizes.p24+80,
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
                            trip['id'],
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
                            'From: ${trip['origin']}',
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
                            'To: ${trip['destination']}',
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
                  _buildDetailTile(context, 'Route', trip['route'], Icons.alt_route),
                  _buildDetailTile(context, 'Duration', trip['duration'], Icons.timer_outlined),
                ],
              ),
              const SizedBox(height: AppSizes.p12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailTile(context, 'Total Fare', trip['fare'], Icons.payments_outlined),
                  _buildDetailTile(context, 'Payment', trip['payment'], Icons.account_balance_wallet_outlined),
                ],
              ),

              const SizedBox(height: AppSizes.p24),

              // Repeat Trip Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/route-results');
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
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    // Filter trips based on search query
    final filteredGroupedTrips = _allTrips.map((group) {
      final matchingTrips = (group['trips'] as List<Map<String, dynamic>>).where((trip) {
        final query = _searchQuery.toLowerCase();
        final dest = trip['destination'].toString().toLowerCase();
        final origin = trip['origin'].toString().toLowerCase();
        final route = trip['route'].toString().toLowerCase();
        return dest.contains(query) || origin.contains(query) || route.contains(query);
      }).toList();

      return {
        'date': group['date'],
        'trips': matchingTrips,
      };
    }).where((group) => (group['trips'] as List).isNotEmpty).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Trip History'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p8,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search past trips, routes, or stages...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
            ),
          ),

          // Trip List View
          Expanded(
            child: filteredGroupedTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history_toggle_off,
                            size: 64, color: AppColors.textSecondaryLight),
                        const SizedBox(height: AppSizes.p16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No Past Trips'
                              : 'No trips matching "$_searchQuery"',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.p16,
                      AppSizes.p8,
                      AppSizes.p16,
                      100, // Bottom padding for shell nav
                    ),
                    itemCount: filteredGroupedTrips.length,
                    itemBuilder: (context, index) {
                      final group = filteredGroupedTrips[index];
                      final trips = group['trips'] as List<Map<String, dynamic>>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: AppSizes.p8),
                            child: Text(
                              group['date'] as String,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textSecondaryLight,
                                  ),
                            ),
                          ),
                          ...trips.map((trip) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: AppSizes.p12),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(AppSizes.p12),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.history,
                                      color: AppColors.primary),
                                ),
                                title: Text(
                                  trip['destination'],
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text('${trip['time']} • ${trip['duration']} • ${trip['route']}'),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      trip['fare'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                    const SizedBox(height: AppSizes.p4),
                                    InkWell(
                                      onTap: () {
                                        context.push('/route-results');
                                      },
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.replay,
                                              size: 12, color: AppColors.primary),
                                          SizedBox(width: 2),
                                          Text(
                                            'Repeat',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
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
                  ),
          ),
        ],
      ),
    );
  }
}
