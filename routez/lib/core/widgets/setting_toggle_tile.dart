import 'package:flutter/material.dart';

class SettingToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }
}
