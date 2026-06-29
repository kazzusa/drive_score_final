import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0D1117);
  static const surface = Color(0xFF1A2030);
  static const surfaceLight = Color(0xFF222B3A);
  static const green = Color(0xFF00E676);
  static const red = Color(0xFFE53935);
  static const yellow = Color(0xFFFFD600);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
  static const textMuted = Color(0xFF555555);
  static const divider = Color(0x15FFFFFF);
  static const cardBorder = Color(0x10FFFFFF);

  static Color scoreColor(int score) {
    if (score >= 75) return green;
    if (score >= 50) return yellow;
    return red;
  }

  static String scoreStatus(int score) {
    if (score >= 75) return 'You are doing great!';
    if (score >= 50) return 'Needs improvement';
    return "Fix your driving behaviour";
  }
}

class AppTheme {
  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.green,
          surface: AppColors.surface,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(color: AppColors.textPrimary),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.green),
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
