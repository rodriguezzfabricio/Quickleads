import 'package:flutter/material.dart';

import '../../core/constants/app_tokens.dart';

class AppTheme {
  static final dark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppTokens.background,
    colorScheme: const ColorScheme.dark(
      primary: AppTokens.primary,
      surface: AppTokens.background,
      onSurface: AppTokens.foreground,
      onPrimary: Colors.white,
      error: AppTokens.danger,
    ),
    useMaterial3: true,
    cardTheme: CardThemeData(
      color: AppTokens.glass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTokens.glassBorder),
      ),
      margin: EdgeInsets.zero,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
      ),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w400),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
    ),
  );
}
