import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/glass_app_bar.dart';
import '../../../../core/widgets/primary_button.dart';

class AddSavedLocationScreen extends StatefulWidget {
  const AddSavedLocationScreen({super.key});

  @override
  State<AddSavedLocationScreen> createState() => _AddSavedLocationScreenState();
}

class _AddSavedLocationScreenState extends State<AddSavedLocationScreen> {
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

  void _saveLocation() {
    if (_formKey.currentState!.validate()) {
      final newLocation = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'icon': _selectedIcon,
        'color': _selectedColor,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.p8),
              Text('Location "${newLocation['name']}" saved successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop(newLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          color: isSelected ? _selectedColor : AppColors.dividerLight,
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
                          color: isSelected ? Colors.white : Colors.transparent,
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
                          ? const Icon(Icons.check, color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.p40),
              PrimaryButton(
                text: 'Save Location',
                onPressed: _saveLocation,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
