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
  final List<Map<String, dynamic>> _transitModes = [
    {'name': 'Matatu', 'icon': Icons.directions_bus_rounded, 'desc': 'Standard matatu routes'},
    {'name': 'Express Bus', 'icon': Icons.departure_board_rounded, 'desc': 'Point-to-point buses'},
    {'name': 'Walking + Matatu', 'icon': Icons.directions_walk_rounded, 'desc': 'Short walks with stages'},
  ];

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
              Text('Profile updated successfully!'),
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

    final cardBg = isDark ? const Color(0xFF161C23) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB),
      appBar: const GlassAppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with Edit Badge
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        size: 54,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Avatar photo upload coming soon!'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.p8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.accent : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBg, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.p24),

              // ── Personal Details Section ────────────────────────────────────
              Text(
                'PERSONAL DETAILS',
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
                        labelText: 'Full Name',
                        prefixIcon: Icon(
                          Icons.person_outline_rounded,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: TextStyle(
                        fontSize: 14.5,
                        color: isDark ? Colors.white : AppColors.textLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        hintText: '+254 7...',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: isDark ? AppColors.accent : AppColors.primary,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: AppSizes.p16),
                    TextFormField(
                      controller: _emailController,
                      enabled: false,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Email Address (Verified)',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSizes.p24),

              // ── Preferred Transit Mode Section ──────────────────────────────
              Text(
                'PREFERRED TRANSIT MODE',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: AppSizes.p8),
              Column(
                children: _transitModes.map((item) {
                  final name = item['name'] as String;
                  final icon = item['icon'] as IconData;
                  final desc = item['desc'] as String;
                  final isSelected = _selectedMode == name;

                  return Container(
                    margin: const EdgeInsets.only(bottom: AppSizes.p8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : cardBorder,
                        width: isSelected ? 1.8 : 1.0,
                      ),
                    ),
                    child: ListTile(
                      onTap: () => setState(() => _selectedMode = name),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      leading: Container(
                        padding: const EdgeInsets.all(AppSizes.p8),
                        decoration: BoxDecoration(
                          color: (isSelected
                                  ? (isDark ? AppColors.accent : AppColors.primary)
                                  : (isDark ? Colors.white12 : Colors.black.withValues(alpha: 0.05)))
                              .withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          icon,
                          color: isSelected
                              ? (isDark ? AppColors.accent : AppColors.primary)
                              : (isDark ? Colors.white54 : AppColors.textSecondaryLight),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : AppColors.textLight,
                        ),
                      ),
                      subtitle: Text(
                        desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle_rounded,
                              color: isDark ? AppColors.accent : AppColors.primary,
                              size: 22,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppSizes.p32),

              PrimaryButton(
                text: isLoading ? 'Saving Changes...' : 'Save Profile Changes',
                isLoading: isLoading,
                onPressed: isLoading ? null : () => _saveProfile(),
              ),

              const SizedBox(height: AppSizes.p24),
            ],
          ),
        ),
      ),
    );
  }
}
