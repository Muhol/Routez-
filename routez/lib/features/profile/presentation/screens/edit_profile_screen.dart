import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/glass_app_bar.dart';
import 'package:routez/core/widgets/primary_button.dart';
import 'package:routez/features/authentication/presentation/providers/auth_provider.dart';
import 'package:routez/features/authentication/presentation/providers/user_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;

  String _selectedMode = 'Matatu';
  final List<String> _transitModes = ['Matatu', 'Express Bus', 'Walking + Matatu'];

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final profile = ref.watch(userProfileProvider).asData?.value;
      final authUser = ref.watch(authStateProvider).asData?.value;

      _nameController.text =
          profile?.displayName ?? authUser?.displayName ?? 'Commuter';
      _emailController.text = profile?.email ?? authUser?.email ?? '';
      _phoneController.text = profile?.phoneNumber ?? '';

      final pref = profile?.defaultTransportPreference ?? 'matatu';
      if (pref == 'express') {
        _selectedMode = 'Express Bus';
      } else if (pref == 'walking') {
        _selectedMode = 'Walking + Matatu';
      } else {
        _selectedMode = 'Matatu';
      }

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    String prefKey = 'matatu';
    if (_selectedMode == 'Express Bus') prefKey = 'express';
    if (_selectedMode == 'Walking + Matatu') prefKey = 'walking';

    final success = await ref
        .read(updateUserProfileControllerProvider.notifier)
        .updateProfile(
          displayName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          defaultTransportPreference: prefKey,
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
              SizedBox(width: AppSizes.p8),
              Text('Profile details updated successfully!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to update profile details.'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final updateState = ref.watch(updateUserProfileControllerProvider);
    final isLoading = updateState.isLoading;

    return Scaffold(
      appBar: const GlassAppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.p20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar with Edit Badge
              Stack(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.person,
                      size: 56,
                      color: AppColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.p8),
                      decoration: const BoxDecoration(
                        color: AppColors.accent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.p8),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Avatar picker opened'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
                child: const Text('Change Photo'),
              ),
              const SizedBox(height: AppSizes.p24),

              // Form Inputs
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Personal Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _emailController,
                enabled: false, // Email managed via Auth
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address (Managed via Auth)',
                  prefixIcon: Icon(Icons.email_outlined),
                ),
              ),
              const SizedBox(height: AppSizes.p16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              // Preferred Transit Mode Chips
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Preferred Transit Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(height: AppSizes.p12),
              Wrap(
                spacing: AppSizes.p8,
                children: _transitModes.map((mode) {
                  final isSelected = _selectedMode == mode;
                  return ChoiceChip(
                    label: Text(mode),
                    selected: isSelected,
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : isDark
                              ? AppColors.textDark
                              : AppColors.textLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedMode = mode);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: AppSizes.p40),

              PrimaryButton(
                text: isLoading ? 'Saving Changes...' : 'Save Changes',
                isLoading: isLoading,
                onPressed: isLoading ? null : () => _saveProfile(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
