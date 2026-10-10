import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color backgroundCream = Color(0xFFF4F0E5);
  static const Color surfacePrimary = Color(0xFFFFFCF5);
  static const Color primaryOrange = Color(0xFFFF922E);
  static const Color highlightYellow = Color(0xFFFFC928);
  static const Color pastelBlue = Color(0xFFA7BFFF);
  static const Color pastelGreen = Color(0xFFBCE8A3);
  static const Color pastelPink = Color(0xFFFFB7B0);
  static const Color pastelPurple = Color(0xFFD6B8FF);
  static const Color darkSlate = Color(0xFF353B50);
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF777777);
  static const Color successGreen = Color(0xFF279B65);
  static const Color errorRed = Color(0xFFE65353);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: AppColors.primaryOrange,
      scaffoldBackgroundColor: AppColors.backgroundCream,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryOrange,
        secondary: AppColors.highlightYellow,
        background: AppColors.backgroundCream,
        surface: AppColors.surfacePrimary,
        error: AppColors.errorRed,
        onPrimary: Colors.white,
        onSecondary: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onSurface: AppColors.textPrimary,
        onError: Colors.white,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunitoSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.nunitoSans(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.nunitoSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.surfacePrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
    );
  }
}
