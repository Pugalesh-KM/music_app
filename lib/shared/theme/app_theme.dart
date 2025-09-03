import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.light.primary,
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.light.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.light.primary,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.light.primaryDark,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.light.surface,
      selectedItemColor: AppColors.light.primary,
      unselectedItemColor: AppColors.light.textGrey,
      showUnselectedLabels: true,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.light.primary,
      inactiveTrackColor: AppColors.light.lightGrey,
      thumbColor: AppColors.accent,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.bold44,
      displayMedium: AppTextStyles.bold32,
      headlineSmall: AppTextStyles.bold20,
      bodyLarge: AppTextStyles.regular16,
      bodyMedium: AppTextStyles.regular14,
      bodySmall: AppTextStyles.regular12,
      labelLarge: AppTextStyles.medium16,
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.light.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
    ),

    cardTheme: CardThemeData(
      color: AppColors.light.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.light.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: AppTextStyles.bold16,
      ),
    ),

  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    primaryColor: AppColors.dark.primary,
    scaffoldBackgroundColor: AppColors.dark.background,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.dark.surface,
      foregroundColor: AppColors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.dark.primaryDark,
      foregroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.dark.surface,
      selectedItemColor: AppColors.dark.primary,
      unselectedItemColor: AppColors.dark.textGrey,
      showUnselectedLabels: true,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.dark.primary,
      inactiveTrackColor: AppColors.dark.lightGrey,
      thumbColor: AppColors.accent,
    ),
    textTheme: TextTheme(
      displayLarge: AppTextStyles.bold44.copyWith(color: AppColors.dark.textPrimary),
      displayMedium: AppTextStyles.bold32.copyWith(color: AppColors.dark.textPrimary),
      headlineSmall: AppTextStyles.bold20.copyWith(color: AppColors.dark.textPrimary),
      bodyLarge: AppTextStyles.regular16.copyWith(color: AppColors.dark.textSecondary),
      bodyMedium: AppTextStyles.regular14.copyWith(color: AppColors.dark.textSecondary),
      bodySmall: AppTextStyles.regular12.copyWith(color: AppColors.dark.textGrey),
      labelLarge: AppTextStyles.medium16.copyWith(color: AppColors.dark.textPrimary),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.dark.primary,
      secondary: AppColors.accent,
      error: AppColors.error,
    ),

    cardTheme: CardThemeData(
      color: AppColors.dark.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.dark.primary,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: AppTextStyles.bold16,
      ),
    ),
  );
}
