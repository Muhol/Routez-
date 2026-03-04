import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip History'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          _buildDateGroup(context, 'Today', [
            _buildTripItem(
              context,
              'Westlands',
              'KES 80',
              '45 mins',
              '10:00 AM',
            ),
          ]),
          const SizedBox(height: AppSizes.p24),
          _buildDateGroup(context, 'Yesterday', [
            _buildTripItem(
              context,
              'CBD, Kencom',
              'KES 50',
              '30 mins',
              '08:30 AM',
            ),
            _buildTripItem(
              context,
              'Pipeline',
              'KES 100',
              '55 mins',
              '05:45 PM',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDateGroup(
    BuildContext context,
    String date,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          date,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: AppSizes.p12),
        ...items,
      ],
    );
  }

  Widget _buildTripItem(
    BuildContext context,
    String destination,
    String fare,
    String duration,
    String time,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.p12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(AppSizes.p12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.history, color: AppColors.primary),
        ),
        title: Text(
          destination,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('$time • $duration'),
        trailing: Text(
          fare,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
        onTap: () {
          // Navigate to details (mocked dialog for now or custom screen)
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Trip Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Destination: $destination'),
                  Text('Fare: $fare'),
                  Text('Duration: $duration'),
                  Text('Time: $time'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
