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
        return Icons.home_rounded;
      case 'work_outlined':
        return Icons.work_rounded;
      case 'fitness_center_outlined':
        return Icons.fitness_center_rounded;
      case 'school_outlined':
        return Icons.school_rounded;
      case 'location_city_outlined':
        return Icons.location_city_rounded;
      case 'star_outline':
        return Icons.star_rounded;
      case 'shopping_bag_outlined':
        return Icons.shopping_bag_rounded;
      case 'directions_bus_outlined':
        return Icons.directions_bus_rounded;
      default:
        return Icons.place_rounded;
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_outlined, color: AppColors.primary),
              SizedBox(width: AppSizes.p8),
              Text('Edit Location',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Location Name',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              TextField(
                controller: addressController,
                decoration: InputDecoration(
                  labelText: 'Stage or Address',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.error),
              SizedBox(width: AppSizes.p8),
              Text('Remove Location',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
              child:
                  const Text('Remove', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(savedLocationsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB),
      appBar: const GlassAppBar(
        title: Text('Saved Places'),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add-saved-location'),
          backgroundColor: isDark ? AppColors.accent : AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            '',
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.2),
          ),
        ),
      ),
      body: locationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => const EmptyStateWidget(
          icon: Icons.cloud_off_outlined,
          title: 'Could Not Load Saved Places',
          message:
              'Unable to reach the database. Check your connection and try again.',
        ),
        data: (locations) {
          if (locations.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.bookmark_border_rounded,
              title: 'No Saved Places',
              message:
                  'Save your everyday spots like Home, Work, and favorite Matatu stages for fast one-tap navigation.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSizes.p16,
              AppSizes.p8,
              AppSizes.p16,
              120, // Bottom padding for FAB & floating nav pills
            ),
            physics: const BouncingScrollPhysics(),
            itemCount: locations.length,
            itemBuilder: (context, index) {
              final item = locations[index];
              final iconData = _parseIcon(item.iconName);
              final color = _parseColor(item.colorHex);

              return Container(
                margin: const EdgeInsets.only(bottom: AppSizes.p12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161C23) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
                      blurRadius: 14,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      context.push(
                        '/route-results',
                        extra: {
                          'origin': 'My Location',
                          'destination': item.address,
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(AppSizes.p14),
                      child: Row(
                        children: [
                          // Custom Icon Badge
                          Container(
                            padding: const EdgeInsets.all(AppSizes.p12),
                            decoration: BoxDecoration(
                              color:
                                  color.withValues(alpha: isDark ? 0.2 : 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(iconData, color: color, size: 22),
                          ),
                          const SizedBox(width: AppSizes.p14),

                          // Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.address,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (item.routes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (isDark
                                              ? AppColors.accent
                                              : AppColors.primary)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                          AppSizes.radiusFull),
                                    ),
                                    child: Text(
                                      item.routes,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark
                                            ? AppColors.accent
                                            : AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Action Buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit_outlined,
                                  size: 18,
                                  color: isDark
                                      ? Colors.white54
                                      : AppColors.textSecondaryLight,
                                ),
                                tooltip: 'Edit',
                                onPressed: () => _showEditDialog(item),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.error,
                                ),
                                tooltip: 'Delete',
                                onPressed: () => _showDeleteDialog(item),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
