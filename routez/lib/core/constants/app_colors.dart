import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Kenyan Transit Blue & Accent Green)
  static const Color primary = Color(0xFF0B2A4A); // Deep Transit Blue
  static const Color primaryLight = Color(0xFF134E85);
  static const Color accent = Color(0xFF1F8F6B); // Transit Green

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // System Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF374151);

  // Glassmorphic / Liquid Glass Tokens
  static Color glassBackgroundLight = Colors.white.withValues(alpha: 0.75);
  static Color glassBorderLight = Colors.white.withValues(alpha: 0.6);
  static Color glassBackgroundDark = const Color(0xFF1E1E1E).withValues(alpha: 0.75);
  static Color glassBorderDark = Colors.white.withValues(alpha: 0.15);
  static Color glassPillLight = const Color(0xFF0B2A4A).withValues(alpha: 0.12);
  static Color glassPillDark = const Color(0xFF1F8F6B).withValues(alpha: 0.25);
}

