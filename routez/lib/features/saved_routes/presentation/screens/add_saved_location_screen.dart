import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/glass_app_bar.dart';
import 'package:routez/core/widgets/primary_button.dart';
import 'package:routez/features/saved_routes/presentation/providers/saved_locations_provider.dart';

class AddSavedLocationScreen extends ConsumerStatefulWidget {
  const AddSavedLocationScreen({super.key});

  @override
  ConsumerState<AddSavedLocationScreen> createState() =>
      _AddSavedLocationScreenState();
}

class _AddSavedLocationScreenState
    extends ConsumerState<AddSavedLocationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();

  IconData _selectedIcon = Icons.place_outlined;
  Color _selectedColor = AppColors.primary;

  final List<IconData> _availableIcons = [
    Icons.home_outlined,
    Icons.work_outlined,
    Icons.fitness_center_outlined,
    Icons.school_outlined,
    Icons.star_outline,
    Icons.place_outlined,
    Icons.shopping_bag_outlined,
    Icons.directions_bus_outlined,
  ];

  final Map<IconData, String> _iconNames = {
    Icons.home_outlined: 'home_outlined',
    Icons.work_outlined: 'work_outlined',
    Icons.fitness_center_outlined: 'fitness_center_outlined',
    Icons.school_outlined: 'school_outlined',
    Icons.star_outline: 'star_outline',
    Icons.place_outlined: 'place_outlined',
    Icons.shopping_bag_outlined: 'shopping_bag_outlined',
    Icons.directions_bus_outlined: 'directions_bus_outlined',
  };

  final List<Color> _availableColors = [
    AppColors.primary,
    AppColors.accent,
    AppColors.info,
    AppColors.warning,
    Colors.purple,
    Colors.pink,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveLocation() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final address = _addressController.text.trim();
    final iconName = _iconNames[_selectedIcon] ?? 'place_outlined';
    final colorHex = _selectedColor.toARGB32().toRadixString(16);

    final success = await ref
        .read(savedLocationsControllerProvider.notifier)
        .addLocation(
          name: name,
          address: address,
          iconName: iconName,
          colorHex: colorHex,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline,
                  color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.p8),
              Text('Location "$name" saved successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save location to Firestore.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedLocationsControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      appBar: const GlassAppBar(
        title: Text('Add Saved Location'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Label & Details',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'e.g. Home, Office, Gym, Campus',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a location name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Stage or Address',
                  hintText: 'e.g. Westlands Stage, Kencom, Pipeline',
                  prefixIcon: Icon(Icons.map_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the stage or address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p24),
              Text(
                'Choose Icon',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.p12),
              Wrap(
                spacing: AppSizes.p12,
                runSpacing: AppSizes.p12,
                children: _availableIcons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _selectedColor.withValues(alpha: 0.2)
                            : Theme.of(context).colorScheme.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? _selectedColor
                              : AppColors.dividerLight,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? _selectedColor
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.p24),
              Text(
                'Badge Color',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: AppSizes.p12),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSizes.p12),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isSelected ? Colors.white : Colors.transparent,
                          width: 3,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),
                      child: isSelected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.p40),
              PrimaryButton(
                text: isLoading ? 'Saving...' : 'Save Location',
                isLoading: isLoading,
                onPressed: isLoading ? null : () => _saveLocation(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
