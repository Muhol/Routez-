import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          _buildDateGroup(context, 'Today', [
            _buildNotificationItem(
              context,
              'Trip Completed',
              'You have arrived at Westlands.',
              true,
            ),
          ]),
          const SizedBox(height: AppSizes.p24),
          _buildDateGroup(context, 'This Week', [
            _buildNotificationItem(
              context,
              'Fare Surge Alert',
              'Fares on Route 23 are higher than usual.',
              false,
            ),
            _buildNotificationItem(
              context,
              'Welcome to Routez!',
              'Thanks for signing up.',
              false,
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

  Widget _buildNotificationItem(
    BuildContext context,
    String title,
    String message,
    bool isUnread,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.p8),
      decoration: BoxDecoration(
        color: isUnread
            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          child: const Icon(Icons.notifications, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text(message),
      ),
    );
  }
}
