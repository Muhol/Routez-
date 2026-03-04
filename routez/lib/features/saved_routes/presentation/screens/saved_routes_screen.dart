import 'package:flutter/material.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';

class SavedRoutesScreen extends StatelessWidget {
  const SavedRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data: empty list means we show EmptyState
    final List<Map<String, String>> savedRoutes = [];

    return Scaffold(
      appBar: AppBar(title: const Text('Saved Routes'), elevation: 0),
      body: savedRoutes.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No Saved Routes',
              message: 'Save your favorite routes to quickly access them here.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.p16),
              itemCount: savedRoutes.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(savedRoutes[index]['name']!),
                  subtitle: Text(savedRoutes[index]['route']!),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppColors.error,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
