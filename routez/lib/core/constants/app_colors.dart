import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Kenyan Transit Blue & Accent Green)
  static const Color primary = Color(0xFF0B2A4A); // Deep Transit Blue
  static const Color primaryLight = Color(0xFF134E85);
  static const Color accent = Color(0xFF1F8F6B); // Transit Green

  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundHighlight = Color.fromARGB(64, 245, 247, 250);

  static const Color surfaceLight = Colors.white;
  static const Color textLight = Color(0xFF111827);
  static const Color textSecondaryLight = Color(0xFF4B5563);

  // Dark Theme Colors (Pure Black OLED background & deep contrast surfaces)
  static const Color backgroundDark = Color(0xFF000000); // Pure Black
  static const Color surfaceDark = Color(0xFF121212); // Deep dark gray for cards & sheets
  static const Color textDark = Color(0xFFF9FAFB);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // System Colors
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Borders & Dividers
  static const Color dividerLight = Color(0xFFE5E7EB);
  static const Color dividerDark = Color(0xFF262626);

  // Glassmorphic / Liquid Glass Tokens (Increased translucency for see-through feel)
  static Color glassBackgroundLight = Colors.white.withValues(alpha: 0.50);
  static Color glassBorderLight = const Color.fromARGB(255, 189, 189, 189).withValues(alpha: 0.70);
  static Color glassBackgroundDark = const Color.fromARGB(255, 49, 49, 49).withValues(alpha: 0.50);
  static Color glassBorderDark = const Color.fromARGB(255, 78, 78, 78).withValues(alpha: 0.18);
  static Color glassPillLight = const Color(0xFF0B2A4A).withValues(alpha: 0.12);
  static Color glassPillDark = const Color(0xFF1F8F6B).withValues(alpha: 0.28);
}
