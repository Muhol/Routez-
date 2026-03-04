import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Provides the current theme mode (Light, Dark, System)
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

// Provides mock settings states
final tripAlertsProvider = StateProvider<bool>((ref) => true);
final fareSurgeProvider = StateProvider<bool>((ref) => false);
final promotionsProvider = StateProvider<bool>((ref) => true);
final bgTrackingProvider = StateProvider<bool>((ref) => true);
final biometricProvider = StateProvider<bool>((ref) => false);
