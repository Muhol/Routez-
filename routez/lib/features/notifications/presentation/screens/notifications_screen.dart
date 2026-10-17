import 'package:flutter/material.dart';
import 'package:routez/core/widgets/empty_state_widget.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        elevation: 0,
      ),
      body: const EmptyStateWidget(
        icon: Icons.notifications_none_outlined,
        title: 'No Notifications',
        message: 'You have no new alerts or trip notifications at this time.',
      ),
    );
  }
}
