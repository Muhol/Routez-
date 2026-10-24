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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout_rounded, color: AppColors.error),
              SizedBox(width: AppSizes.p8),
              Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold)),
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
              child: const Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(userProfileProvider);
    final authUser = ref.watch(authStateProvider).asData?.value;

    final cardBg = isDark ? const Color(0xFF161C23) : Colors.white;
    final cardBorder = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFF7F9FB),
      appBar: const GlassAppBar(
        title: Text('Account Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p20, vertical: AppSizes.p16),
        physics: const BouncingScrollPhysics(),
        children: [
          // ── Header Profile Card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSizes.p20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cardBorder, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.15),
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: isDark ? AppColors.accent : AppColors.primary,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: () => context.push('/edit-profile'),
                        borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                        child: Container(
                          padding: const EdgeInsets.all(AppSizes.p6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.accent : AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: cardBg, width: 2),
                          ),
                          child: const Icon(
                            Icons.edit_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.p12),

                profileAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  error: (_, __) => Column(
                    children: [
                      Text(
                        authUser?.displayName ?? 'Nairobi Commuter',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        authUser?.email ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  data: (profile) {
                    final displayName = profile?.displayName ?? authUser?.displayName ?? 'Nairobi Commuter';
                    final email = profile?.email ?? authUser?.email ?? '';
                    final phone = profile?.phoneNumber ?? '';

                    return Column(
                      children: [
                        Text(
                          displayName,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                              ),
                              child: Text(
                                'Verified Rider',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.accent : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          [email, if (phone.isNotEmpty) phone].join('  •  '),
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.p24),

          // ── Account & Commute Section ───────────────────────────────────────
          Text(
            'COMMUTE & PREFERENCES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder, width: 1.2),
            ),
            child: Column(
              children: [
                _buildOptionRow(
                  context: context,
                  icon: Icons.person_outline_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Name, phone number & default transit mode',
                  isDark: isDark,
                  onTap: () => context.push('/edit-profile'),
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                _buildOptionRow(
                  context: context,
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  subtitle: 'Route delays, stage alerts & notifications',
                  isDark: isDark,
                  onTap: () => context.push('/notifications'),
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                _buildOptionRow(
                  context: context,
                  icon: Icons.tune_rounded,
                  title: 'Preferences & Settings',
                  subtitle: 'Theme (Dark/Light), storage & security',
                  isDark: isDark,
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.p24),

          // ── Support & About Section ─────────────────────────────────────────
          Text(
            'SUPPORT & ABOUT',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppSizes.p8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: cardBorder, width: 1.2),
            ),
            child: Column(
              children: [
                _buildOptionRow(
                  context: context,
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Matatu Stage Guide',
                  subtitle: 'FAQs, Nairobi CBD stage guide & routes',
                  isDark: isDark,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Support guide coming soon!')),
                    );
                  },
                ),
                Divider(height: 1, color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                _buildOptionRow(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: 'About Routez',
                  subtitle: 'Version 1.0.0 (Kenyan Matatu Transit)',
                  isDark: isDark,
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Routez',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.directions_bus_rounded, color: AppColors.primary),
                      children: const [
                        Text('Routez is Nairobi\'s smartest Matatu and transit navigation assistant.'),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.p24),

          // ── Logout Button ───────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _showLogoutDialog(context, ref),
              icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
              label: const Text(
                'Log Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4), width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),

          const SizedBox(height: AppSizes.p32),
        ],
      ),
    );
  }

  Widget _buildOptionRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.p16, vertical: AppSizes.p14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSizes.p8),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.accent : AppColors.primary).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.accent : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.p14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white54 : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : AppColors.textSecondaryLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
