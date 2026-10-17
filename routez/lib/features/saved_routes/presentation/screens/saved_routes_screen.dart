import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/empty_state_widget.dart';
import 'package:routez/core/widgets/glass_app_bar.dart';
import 'package:routez/features/saved_routes/data/models/saved_location_model.dart';
import 'package:routez/features/saved_routes/presentation/providers/saved_locations_provider.dart';

class SavedRoutesScreen extends ConsumerStatefulWidget {
  const SavedRoutesScreen({super.key});

  @override
  ConsumerState<SavedRoutesScreen> createState() => _SavedRoutesScreenState();
}

class _SavedRoutesScreenState extends ConsumerState<SavedRoutesScreen> {
  IconData _parseIcon(String iconName) {
    switch (iconName) {
      case 'home_outlined':
        return Icons.home_outlined;
      case 'work_outlined':
        return Icons.work_outlined;
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'location_city_outlined':
        return Icons.location_city_outlined;
      case 'star_outline':
        return Icons.star_outline;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_outlined;
      case 'directions_bus_outlined':
        return Icons.directions_bus_outlined;
      default:
        return Icons.place_outlined;
    }
  }

  Color _parseColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      final val = int.parse(hex, radix: 16);
      return Color(val.toUnsigned(32));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _showEditDialog(SavedLocation item) {
    final titleController = TextEditingController(text: item.name);
    final addressController = TextEditingController(text: item.address);

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
              onPressed: () async {
                final newName = titleController.text.trim();
                final newAddress = addressController.text.trim();

                if (newName.isNotEmpty && newAddress.isNotEmpty) {
                  final messenger = ScaffoldMessenger.of(context);
                  Navigator.pop(context);
                  await ref
                      .read(savedLocationsControllerProvider.notifier)
                      .updateLocation(
                        item.id,
                        name: newName,
                        address: newAddress,
                      );
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('Saved location updated!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(SavedLocation item) {
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
            'Are you sure you want to remove "${item.name}" from your saved locations?',
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
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(context);
                await ref
                    .read(savedLocationsControllerProvider.notifier)
                    .deleteLocation(item.id);
                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Removed "${item.name}"'),
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
    final locationsAsync = ref.watch(savedLocationsProvider);

    return Scaffold(
      appBar: const GlassAppBar(
        title: Text('Saved Routes'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add-saved-location'),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Add Location'),
        ),
      ),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const EmptyStateWidget(
          icon: Icons.cloud_off_outlined,
          title: 'Could Not Load Saved Routes',
          message: 'Unable to reach the database. Check your connection and try again.',
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.bookmark_border,
              title: 'No Saved Locations',
              message:
                  'Save your favorite destinations and stages to access them quickly.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p16,
              AppSizes.p16,
              AppSizes.p16,
              100, // Bottom padding for FAB & nav bar
            ),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final item = locations[index];
              final iconData = _parseIcon(item.iconName);
              final color = _parseColor(item.colorHex);

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
                    item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSizes.p4),
                      Text(item.address),
                      const SizedBox(height: AppSizes.p2),
                      Text(
                        item.routes,
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
                        onPressed: () => _showEditDialog(item),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          size: 20,
                          color: AppColors.error,
                        ),
                        tooltip: 'Delete location',
                        onPressed: () => _showDeleteDialog(item),
                      ),
                    ],
                  ),
                  onTap: () => context.push('/route-results'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
