import 'package:flutter/material.dart';

/// Paleta de colores basada en el logo de mueve
class MueveColors {
  // Colores principales del logo
  static const Color darkNavy = Color(0xFF2C3E50);      // Azul oscuro del logo
  static const Color brightOrange = Color(0xFFE67E22);  // Naranja vibrante
  static const Color skyBlue = Color(0xFF3498DB);       // Azul cielo
  static const Color lightBlue = Color(0xFF74B9FF);     // Azul claro
  static const Color cream = Color(0xFFF8F9FA);         // Crema suave
  
  // Colores de soporte
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F6FA);
  static const Color mediumGray = Color(0xFFDDD6FE);
  static const Color darkGray = Color(0xFF636E72);
  
  // Colores de estado
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFE17055);
  static const Color error = Color(0xFFD63031);
  static const Color info = Color(0xFF74B9FF);
  
  // Gradientes del logo
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [skyBlue, lightBlue],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brightOrange, Color(0xFFE55A4F)],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [cream, pureWhite],
  );
  
  // Colores de texto
  static const Color primaryText = darkNavy;
  static const Color secondaryText = darkGray;
  static const Color lightText = pureWhite;
}
