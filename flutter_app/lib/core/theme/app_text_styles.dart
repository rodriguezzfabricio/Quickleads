import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static const String _font = '.SF Pro Display';

  static const h1 = TextStyle(
    fontFamily: _font,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.68,
    height: 1.15,
    color: AppColors.foreground,
  );

  static const h2 = TextStyle(
    fontFamily: _font,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.22,
    height: 1.25,
    color: AppColors.foreground,
  );

  static const h3 = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.foreground,
  );

  static const h4 = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.foreground,
  );

  static const body = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.foreground,
  );

  static const secondary = TextStyle(
    fontFamily: _font,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.mutedFg,
  );

  static const label = TextStyle(
    fontFamily: _font,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.39,
    height: 1.4,
    color: AppColors.mutedFg,
  );

  static const badge = TextStyle(
    fontFamily: _font,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.foreground,
  );

  static const tiny = TextStyle(
    fontFamily: _font,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.mutedFg,
  );

  static final sectionLabel = badge.copyWith(
    letterSpacing: 0.55,
    color: AppColors.mutedFg,
  );

  static const buttonPrimary = TextStyle(
    fontFamily: _font,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: Colors.white,
  );
}
