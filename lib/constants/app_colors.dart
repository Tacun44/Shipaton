import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color darkNavy = Color(0xFF2D3748);      // Main background
  static const Color accentOrange = Color(0xFFD69E2E);  // Warm accent
  static const Color pureWhite = Color(0xFFFFFFFF);     // Primary text/background
  static const Color skyBlue = Color(0xFF4299E1);       // Cool accent
  static const Color purple = Color(0xFF805AD5);        // Secondary accent
  static const Color lightGray = Color(0xFFF7FAFC);     // Subtle backgrounds
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [darkNavy, Color(0xFF1A202C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentOrange, Color(0xFFED8936)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [skyBlue, Color(0xFF3182CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Text Colors
  static const Color primaryText = Color(0xFF2D3748);
  static const Color secondaryText = Color(0xFF4A5568);
  static const Color lightText = Color(0xFF718096);
  
  // Status Colors
  static const Color success = Color(0xFF38A169);
  static const Color error = Color(0xFFE53E3E);
  static const Color warning = Color(0xFFD69E2E);
  static const Color info = Color(0xFF3182CE);
}
