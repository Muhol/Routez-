import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/glass_app_bar.dart';

class SavedRoutesScreen extends StatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  State<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends State<SavedRoutesScreen> {
  final List<Map<String, dynamic>> _savedLocations = [
    {
      'name': 'Home',
      'address': 'Pipeline, Outering Road Stage',
      'icon': Icons.home_outlined,
      'color': AppColors.primary,
      'routes': 'Route 23, 110 Express',
    },
    {
      'name': 'Work / Office',
      'address': 'Westlands Stage, Waiyaki Way',
      'icon': Icons.work_outlined,
      'color': AppColors.accent,
      'routes': 'Route 23, 105',
    },
    {
      'name': 'Gym',
      'address': 'Taj Mall Stage, Fedha',
      'icon': Icons.fitness_center_outlined,
      'color': AppColors.info,
      'routes': 'Route 46, 33',
    },
    {
      'name': 'City Center',
      'address': 'Kencom Stage, CBD',
      'icon': Icons.location_city_outlined,
      'color': AppColors.warning,
      'routes': 'Route 100, 102',
    },
  ];

  void _navigateToAddLocation() async {
    final result = await context.push<Map<String, dynamic>>('/add-saved-location');
    if (result != null) {
      setState(() {
        _savedLocations.add({
          'name': result['name'],
          'address': result['address'],
          'icon': result['icon'] ?? Icons.place_outlined,
          'color': result['color'] ?? AppColors.primary,
          'routes': 'Direct Matatu Route',
        });
      });
    }
  }

  void _showEditDialog(int index) {
    final item = _savedLocations[index];
    final titleController = TextEditingController(text: item['name']);
    final addressController = TextEditingController(text: item['address']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primary),
              SizedBox(width: AppSizes.p8),
              Text('Edit Location'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Stage or Address',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _savedLocations[index]['name'] = titleController.text.trim();
                  _savedLocations[index]['address'] = addressController.text.trim();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Saved location updated!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(int index) {
    final item = _savedLocations[index];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: AppSizes.p8),
              Text('Remove Location'),
            ],
          ),
          content: Text(
            'Are you sure you want to remove "${item['name']}" from your saved locations?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () {
                setState(() {
                  _savedLocations.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed "${item['name']}"'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GlassAppBar(
        title: Text('Saved Routes & Places'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Position above glass bottom nav
        child: FloatingActionButton.extended(
          onPressed: _navigateToAddLocation,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Location'),
        ),
      ),
      body: _savedLocations.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No Saved Locations',
              message: 'Save your favorite destinations and stages to access them quickly.',
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSizes.p16,
                AppSizes.p16,
                AppSizes.p16,
                100, // Bottom padding for FAB & nav bar
              ),
              itemCount: _savedLocations.length,
              itemBuilder: (context, index) {
                final item = _savedLocations[index];
                final iconData = item['icon'] as IconData;
                final color = item['color'] as Color;

                return Card(
                  margin: const EdgeInsets.only(bottom: AppSizes.p12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.p16,
                      vertical: AppSizes.p8,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(iconData, color: color),
                    ),
                    title: Text(
                      item['name']!,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSizes.p4),
                        Text(item['address']!),
                        const SizedBox(height: AppSizes.p2),
                        Text(
                          item['routes']!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          tooltip: 'Edit location',
                          onPressed: () => _showEditDialog(index),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: AppColors.error,
                          ),
                          tooltip: 'Delete location',
                          onPressed: () => _showDeleteDialog(index),
                        ),
                      ],
                    ),
                    onTap: () => context.push('/route-results'),
                  ),
                );
              },
            ),
    );
  }
}
