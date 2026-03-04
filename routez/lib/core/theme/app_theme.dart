import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceLight,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textLight,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: AppColors.textLight,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textLight,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: AppColors.textLight),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondaryLight),
        labelLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p16,
            horizontal: AppSizes.p24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 2),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p16,
            horizontal: AppSizes.p24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.all(AppSizes.p16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryLight),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLarge),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceLight,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondaryLight,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.surfaceDark,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textDark,
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.inter(
          color: AppColors.textDark,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: GoogleFonts.inter(
          color: AppColors.textDark,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(color: AppColors.textDark),
        bodyMedium: GoogleFonts.inter(color: AppColors.textSecondaryDark),
        labelLarge: GoogleFonts.inter(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p16,
            horizontal: AppSizes.p24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white, width: 2),
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.p16,
            horizontal: AppSizes.p24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          ),
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textDark,
          textStyle: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.all(AppSizes.p16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.dividerDark, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        hintStyle: GoogleFonts.inter(color: AppColors.textSecondaryDark),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSizes.radiusLarge),
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
