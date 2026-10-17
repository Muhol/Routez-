import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:routez/core/constants/app_sizes.dart';
import 'package:routez/core/constants/app_colors.dart';
import 'package:routez/core/widgets/glass_app_bar.dart';
import 'package:routez/features/authentication/presentation/providers/auth_provider.dart';
import 'package:routez/features/authentication/presentation/providers/user_profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              SizedBox(width: AppSizes.p8),
              Text('Confirm Logout'),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of your Routez account?',
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
                Navigator.pop(context);
                await ref.read(authControllerProvider.notifier).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(authStateProvider).asData?.value;

    return Scaffold(
      appBar: const GlassAppBar(
        title: Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSizes.p16,
          AppSizes.p16,
          AppSizes.p16,
          100, // Bottom space for bottom nav shell
        ),
        children: [
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.person,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: InkWell(
                    onTap: () => context.push('/edit-profile'),
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.p6),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSizes.p16),

          profileAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, __) => Column(
              children: [
                Text(
                  authUser?.displayName ?? 'Commuter',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Text(
                  authUser?.email ?? '',
                  style: const TextStyle(color: AppColors.textSecondaryLight),
                ),
              ],
            ),
            data: (profile) {
              final displayName = profile?.displayName ??
                  authUser?.displayName ??
                  'Commuter';
              final email = profile?.email ?? authUser?.email ?? '';
              final phone = profile?.phoneNumber ?? 'No phone added';

              return Column(
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '$email  •  $phone',
                    style: const TextStyle(color: AppColors.textSecondaryLight),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: AppSizes.p32),

          _buildProfileOption(
            context,
            Icons.edit_outlined,
            'Edit Profile',
            'Name, photo, phone & transit mode',
            () => context.push('/edit-profile'),
          ),
          _buildProfileOption(
            context,
            Icons.notifications_outlined,
            'Notifications',
            'Trip alerts, delays & fare updates',
            () => context.push('/notifications'),
          ),
          _buildProfileOption(
            context,
            Icons.settings_outlined,
            'Settings',
            'Theme, security & preferences',
            () => context.push('/settings'),
          ),
          _buildProfileOption(
            context,
            Icons.help_outline,
            'Help & Support',
            'FAQs, stage guide & feedback',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Support center coming soon!')),
              );
            },
          ),
          _buildProfileOption(
            context,
            Icons.info_outline,
            'About Routez',
            'Version 1.0.0 (Kenyan Transit)',
            () {
              showAboutDialog(
                context: context,
                applicationName: 'Routez',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.directions_bus,
                    color: AppColors.primary),
                children: const [
                  Text(
                      'Routez is Nairobi\'s smartest Matatu and transit navigation assistant.'),
                ],
              );
            },
          ),

          const SizedBox(height: AppSizes.p32),
          ElevatedButton(
            onPressed: () => _showLogoutDialog(context, ref),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.p8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
