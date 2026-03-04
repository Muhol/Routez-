import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/primary_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), elevation: 0),
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.p16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.dividerLight,
              child: Icon(
                Icons.person,
                size: 50,
                color: AppColors.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: AppSizes.p16),
          const Center(
            child: Text(
              'Jane Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const Center(
            child: Text(
              'jane.doe@example.com',
              style: TextStyle(color: AppColors.textSecondaryLight),
            ),
          ),
          const SizedBox(height: AppSizes.p32),
          _buildProfileOption(
            context,
            Icons.edit_outlined,
            'Edit Profile',
            () {},
          ),
          _buildProfileOption(
            context,
            Icons.notifications_outlined,
            'Notifications',
            () => context.push('/notifications'),
          ),
          _buildProfileOption(
            context,
            Icons.settings_outlined,
            'Settings',
            () => context.push('/settings'),
          ),
          _buildProfileOption(
            context,
            Icons.help_outline,
            'Help & Support',
            () {},
          ),
          _buildProfileOption(context, Icons.info_outline, 'About', () {}),
          const SizedBox(height: AppSizes.p32),
          PrimaryButton(
            text: 'Logout',
            isOutlined: true,
            onPressed: () => context.go('/welcome'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
