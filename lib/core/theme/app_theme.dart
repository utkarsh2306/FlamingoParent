import 'package:flutter/material.dart';

class AppTheme {
  // Flamingo color palette
  static const Color primary = Color(0xFFFF6B9D);
  static const Color primaryDark = Color(0xFFE91E8C);
  static const Color secondary = Color(0xFFFF9A3C);
  static const Color accent = Color(0xFF845EC2);
  static const Color background = Color(0xFFFFF0F5);
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF00C9A7);
  static const Color error = Color(0xFFFF5C7C);
  static const Color textPrimary = Color(0xFF2D1B69);
  static const Color textSecondary = Color(0xFF9B8CB0);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFFF9A3C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF845EC2), Color(0xFFFF6B9D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF4FACFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
      );
}
