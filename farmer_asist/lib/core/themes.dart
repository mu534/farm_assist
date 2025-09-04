import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryIndigo = Color(0xFF4F46E5); // Indigo
  static const Color accentEmerald = Color(0xFF10B981); // Emerald
  static const Color backgroundLight = Color(0xFFF9FAFB); // Nearly white
  static const Color backgroundGray = Color(0xFFE5E7EB); // Light gray
  static const Color textDark = Color(0xFF111827); // Deep charcoal
  static const Color textLight = Color(0xFF6B7280); // Medium gray
  static const Color errorRed = Color(0xFFDC2626); // Error state
  static const Color shadowColor = Colors.black12;
}

class AppTextStyles {
  static const String fontFamilyInter = 'Inter';
  static const String fontFamilyOpenSans = 'OpenSans';

  static const TextStyle heading1 = TextStyle(
    fontFamily: fontFamilyInter,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const TextStyle heading2 = TextStyle(
    fontFamily: fontFamilyInter,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const TextStyle bodyText = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textDark,
  );

  static const TextStyle bodyTextLight = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textLight,
  );

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamilyOpenSans,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

final ThemeData lightTheme = ThemeData(
  primaryColor: AppColors.primaryIndigo,
  scaffoldBackgroundColor: AppColors.backgroundLight,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.backgroundLight,
    elevation: 0,
    iconTheme: IconThemeData(color: AppColors.textDark),
    titleTextStyle: AppTextStyles.heading2,
  ),
  textTheme: const TextTheme(
    displayLarge: AppTextStyles.heading1,
    displayMedium: AppTextStyles.heading2,
    bodyLarge: AppTextStyles.bodyText,
    bodyMedium: AppTextStyles.bodyTextLight,
    labelLarge: AppTextStyles.buttonText,
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryIndigo,
    secondary: AppColors.accentEmerald,
    surface: Colors.white,
    error: AppColors.errorRed,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: AppColors.textDark,
    onError: Colors.white,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.white,
      backgroundColor: AppColors.primaryIndigo,
      textStyle: AppTextStyles.buttonText,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
);
