import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static final dark = ThemeData.dark(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.systemBlue,
      secondary: AppColors.systemBlue,
      surface: AppColors.glassElevated,
      error: AppColors.systemRed,
      onSurface: AppColors.foreground,
      onPrimary: Colors.white,
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.h1,
      displayMedium: AppTextStyles.h2,
      headlineSmall: AppTextStyles.h3,
      titleMedium: AppTextStyles.h4,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.secondary,
      labelLarge: AppTextStyles.label,
      labelMedium: AppTextStyles.badge,
      labelSmall: AppTextStyles.tiny,
    ),
    dividerColor: AppColors.glassBorder,
    cardColor: AppColors.glassElevated,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.foreground,
      centerTitle: false,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassElevated,
      hintStyle: AppTextStyles.body.copyWith(color: AppColors.mutedFg),
      labelStyle: AppTextStyles.label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide:
            BorderSide(color: AppColors.systemBlue.withValues(alpha: 0.5)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.systemBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(56),
        textStyle: AppTextStyles.buttonPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.foreground,
        side: const BorderSide(color: AppColors.glassBorder),
        minimumSize: const Size.fromHeight(48),
        textStyle: AppTextStyles.h4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.systemBlue,
        textStyle:
            AppTextStyles.secondary.copyWith(color: AppColors.systemBlue),
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      modalBackgroundColor: Colors.transparent,
    ),
    splashFactory: NoSplash.splashFactory,
  );
}
