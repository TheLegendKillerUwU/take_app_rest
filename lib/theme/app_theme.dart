import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds
  static const Color backgroundDark = Color(0xFF1A1F2E);
  static const Color backgroundPurple = Color(0xFF2D2640);
  static const Color headerPurple = Color(0xFF2A2340);

  // Accent
  static const Color gold = Color(0xFFBFA140);
  static const Color goldLight = Color(0xFFCFB04A);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSubtitle = Color(0xFFB0B8CC);
  static const Color textGold = Color(0xFFCFB04A);
  static const Color textDark = Color(0xFF1A1F2E);

  // Fields
  static const Color fieldBackground = Color(0xFFEAE8F0);
  static const Color fieldBorder = Color(0xFFD0CCDC);
  static const Color labelText = Color(0xFF4A4560);

  // Back button
  static const Color backButton = Color(0xFF6B5BDB);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: 'sans-serif',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold,
        surface: AppColors.backgroundDark,
      ),
    );
  }
}
