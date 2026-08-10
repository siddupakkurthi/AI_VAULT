import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF6C3EE8);
  static const Color primaryLight = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF4C1D95);

  // Emergency / Accent
  static const Color emergency = Color(0xFFEF4444);
  static const Color emergencyLight = Color(0xFFFCA5A5);
  static const Color emergencyDark = Color(0xFFB91C1C);

  // Success / Safe
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF6EE7B7);

  // Warning
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFCD34D);

  // Info
  static const Color info = Color(0xFF3B82F6);

  // Blood Group Red
  static const Color bloodRed = Color(0xFFDC2626);

  // Dark Theme
  static const Color darkBg = Color(0xFF0F0A1E);
  static const Color darkSurface = Color(0xFF1A1033);
  static const Color darkCard = Color(0xFF241848);
  static const Color darkBorder = Color(0xFF3D2D6B);

  // Light Theme
  static const Color lightBg = Color(0xFFF5F3FF);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFEDE9FE);
  static const Color lightBorder = Color(0xFFDDD6FE);

  // Text
  static const Color textLight = Color(0xFFF8F8FF);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color textDark = Color(0xFF1F1735);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C3EE8), Color(0xFF9B59B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emergencyGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0F0A1E), Color(0xFF1A1033)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF241848), Color(0xFF1A1033)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
