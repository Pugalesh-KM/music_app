import 'package:flutter/material.dart';

class AppColors {

  static final light = _LightColors();
  static final dark = _DarkColors();

  static const Color accent = Color(0xFFFF7043);
  static const Color error = Color(0xFFEF5350);
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFCA28);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
}

class _LightColors {
  final Color primary = const Color(0xFF00897B);
  final Color primaryDark = const Color(0xFF00695C);

  final Color background = const Color(0xFFF1FDFB);
  final Color surface = const Color(0xFFFFFFFF);
  final Color gradientStart = const Color(0xFF80CBC4);
  final Color gradientEnd = const Color(0xFFE0F2F1);

  final Color textPrimary = const Color(0xFF102A2A);
  final Color textSecondary = const Color(0xFF37474F);
  final Color textGrey = const Color(0xFF9E9E9E);

  final Color lightGrey = const Color(0xFFCFD8DC);
  final Color darkGrey = const Color(0xFF455A64);
}

class _DarkColors {
  final Color primary = const Color(0xFF4DB6AC);
  final Color primaryDark = const Color(0xFF26A69A);

  final Color background = const Color(0xFF121212);
  final Color surface = const Color(0xFF1E1E1E);
  final Color gradientStart = const Color(0xFF004D40);
  final Color gradientEnd = const Color(0xFF00251A);

  final Color textPrimary = const Color(0xFFFFFFFF);
  final Color textSecondary = const Color(0xFFB0BEC5);
  final Color textGrey = const Color(0xFF757575);

  final Color lightGrey = const Color(0xFF37474F);
  final Color darkGrey = const Color(0xFF90A4AE);
}
