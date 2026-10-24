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

  IconData _selectedIcon = Icons.home_rounded;
  Color _selectedColor = AppColors.primary;

  final List<IconData> _availableIcons = [
    Icons.home_rounded,
    Icons.work_rounded,
    Icons.fitness_center_rounded,
    Icons.school_rounded,
    Icons.star_rounded,
    Icons.place_rounded,
    Icons.shopping_bag_rounded,
    Icons.directions_bus_rounded,
  ];

  final Map<IconData, String> _iconNames = {
    Icons.home_rounded: 'home_outlined',
    Icons.work_rounded: 'work_outlined',
    Icons.fitness_center_rounded: 'fitness_center_outlined',
    Icons.school_rounded: 'school_outlined',
    Icons.star_rounded: 'star_outline',
    Icons.place_rounded: 'place_outlined',
    Icons.shopping_bag_rounded: 'shopping_bag_outlined',
    Icons.directions_bus_rounded: 'directions_bus_outlined',
  };

  final List<Color> _availableColors = [
    const Color(0xFF1E88E5), // Blue
    const Color(0xFF00BFA5), // Teal
    const Color(0xFFFF9800), // Amber
    const Color(0xFF7C4DFF), // Purple
    const Color(0xFFE91E63), // Pink
    const Color(0xFF43A047), // Green
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
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              const SizedBox(width: AppSizes.p8),
              Text('Location "$name" saved!'),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(savedLocationsControllerProvider);
    final isLoading = state.isLoading;

    final cardBg = isDark ? const Color(0xFF161C23) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);

    final previewName = _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Place Name';
    final previewAddress = _addressController.text.trim().isNotEmpty
        ? _addressController.text.trim()
        : 'Stage or landmark address';

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB),
      appBar: const GlassAppBar(
        title: Text('Add Saved Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Live Preview Card ───────────────────────────────────────────
              Text(
                'LIVE PREVIEW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSizes.p12),
                      decoration: BoxDecoration(
                        color: _selectedColor.withValues(alpha: isDark ? 0.22 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_selectedIcon, color: _selectedColor, size: 24),
                    ),
                    const SizedBox(width: AppSizes.p14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            previewName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            previewAddress,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // ── Details Section ─────────────────────────────────────────────
              Text(
                'DETAILS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Container(
                padding: const EdgeInsets.all(AppSizes.p16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: cardBorder, width: 1.2),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isDark ? Colors.white : AppColors.textLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Place Name',
                        hintText: 'e.g. Home, Office, Gym, Campus',
                        prefixIcon: Icon(
                          Icons.label_outline_rounded,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name for this place';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSizes.p16),
                    TextFormField(
                      controller: _addressController,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isDark ? Colors.white : AppColors.textLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Stage or Address',
                        hintText: 'e.g. Westlands Stage, Kencom, Pipeline',
                        prefixIcon: Icon(
                          Icons.place_outlined,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter the stage or landmark address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // ── Choose Icon Section ─────────────────────────────────────────
              Text(
                'CHOOSE ICON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p10),
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
                            ? _selectedColor.withValues(alpha: isDark ? 0.3 : 0.15)
                            : cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? _selectedColor : cardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 22,
                        color: isSelected ? _selectedColor : (isDark ? Colors.white70 : AppColors.textLight),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.p24),

              // ── Badge Color Section ─────────────────────────────────────────
              Text(
                'BADGE COLOR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p10),
              Row(
                children: _availableColors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: AppSizes.p14),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.transparent,
                          width: 2.5,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                )
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.p32),

              PrimaryButton(
                text: isLoading ? 'Saving Place...' : 'Save Place',
                isLoading: isLoading,
                onPressed: isLoading ? null : () => _saveLocation(),
              ),
              const SizedBox(height: AppSizes.p20),
            ],
          ),
        ),
      ),
    );
  }
}
