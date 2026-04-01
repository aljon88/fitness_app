import 'package:flutter/material.dart';

/// Professional color scheme for FitFlow app
/// Inspired by modern fitness apps with realistic, clean design
class AppColors {
  // Primary Colors - Professional Blue
  static const Color primary = Color(0xFF1E88E5); // Material Blue 600
  static const Color primaryLight = Color(0xFF42A5F5); // Material Blue 400
  static const Color primaryDark = Color(0xFF1565C0); // Material Blue 800
  
  // Accent Colors
  static const Color accent = Color(0xFF00BFA5); // Teal Accent
  static const Color accentLight = Color(0xFF1DE9B6); // Teal Accent Light
  
  // Background Colors - Dark Theme
  static const Color background = Color(0xFF121212); // Pure dark
  static const Color backgroundLight = Color(0xFF1E1E1E); // Slightly lighter
  static const Color backgroundMedium = Color(0xFF2A2A2A); // Medium gray
  static const Color surface = Color(0xFF2C2C2C); // Card/surface color
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White
  static const Color textSecondary = Color(0xFFB0B0B0); // Light gray
  static const Color textTertiary = Color(0xFF808080); // Medium gray
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color error = Color(0xFFF44336); // Red
  static const Color info = Color(0xFF2196F3); // Blue
  
  // Exercise/Workout Colors
  static const Color exerciseActive = Color(0xFF1E88E5); // Blue
  static const Color exerciseRest = Color(0xFF00BFA5); // Teal
  static const Color exerciseComplete = Color(0xFF4CAF50); // Green
  
  // Gradient Combinations
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [background, backgroundLight, backgroundMedium],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadow Colors
  static Color primaryShadow = primary.withOpacity(0.3);
  static Color accentShadow = accent.withOpacity(0.3);
  
  // Opacity Helpers
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}

/// Professional typography for FitFlow app
class AppTypography {
  // Display Text (Large headings)
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
    letterSpacing: 0.5,
  );
  
  // Headline Text
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );
  
  // Title Text
  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
  
  // Body Text
  static const TextStyle body = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );
  
  // Caption Text
  static const TextStyle caption = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );
  
  // Button Text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}
