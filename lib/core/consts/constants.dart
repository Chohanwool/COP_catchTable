import 'package:flutter/material.dart';

const kPhonePrefixPh = '09';

/// 앱 전체 색상 팔레트
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primary = Color(0xFFF06F1A); // Orange
  static const Color background = Color(0xFFF5F5F5); // Light grey background

  // Text colors
  static const Color textPrimary = Color(0xFF333333); // Dark grey
  static const Color textSecondary = Color(0xFF666666); // Medium grey

  // Grey scale
  static const Color grey = Color(0xFF999999);
  static const Color lightGrey = Color(0xFFE0E0E0);

  // Functional colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFA726);
}
