import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/widgets/setting_toggle_tile.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), elevation: 0),
      body: ListView(
        children: [
          _buildSectionHeader('Appearance'),
          ListTile(
            title: const Text('Dark Mode'), 
            trailing: Switch(
              value: isDark, 
              onChanged: (val) {
                ref.read(themeModeProvider.notifier).state = val ? ThemeMode.dark : ThemeMode.light;
              }
            ),
          ),
          
          _buildSectionHeader('Language'),
          ListTile(title: const Text('App Language'), trailing: const Text('English'), onTap: () {}),
          
          _buildSectionHeader('Notifications'),
          SettingToggleTile(
            title: 'Trip Alerts', 
            value: ref.watch(tripAlertsProvider), 
            onChanged: (v) => ref.read(tripAlertsProvider.notifier).state = v,
          ),
          SettingToggleTile(
            title: 'Fare Surge Alerts', 
            value: ref.watch(fareSurgeProvider), 
            onChanged: (v) => ref.read(fareSurgeProvider.notifier).state = v,
          ),
          SettingToggleTile(
            title: 'Promotions', 
            value: ref.watch(promotionsProvider), 
            onChanged: (v) => ref.read(promotionsProvider.notifier).state = v,
          ),

          _buildSectionHeader('Location Settings'),
          SettingToggleTile(
            title: 'Background Tracking', 
            subtitle: 'Needed for step-by-step guidance', 
            value: ref.watch(bgTrackingProvider), 
            onChanged: (v) => ref.read(bgTrackingProvider.notifier).state = v,
          ),

          _buildSectionHeader('Privacy & Security'),
          SettingToggleTile(
            title: 'Enable Biometric Login', 
            value: ref.watch(biometricProvider), 
            onChanged: (v) => ref.read(biometricProvider.notifier).state = v,
          ),
          ListTile(title: const Text('Change Password'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(title: const Text('Manage Data'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(title: const Text('Clear Trip History', style: TextStyle(color: Colors.red)), onTap: () {}),

          _buildSectionHeader('About'),
          ListTile(title: const Text('App Version'), trailing: const Text('1.0.0')),
          ListTile(title: const Text('Terms & Conditions'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          const SizedBox(height: AppSizes.p32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.p16, top: AppSizes.p24, bottom: AppSizes.p8),
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }
}
