import 'package:flutter/material.dart';
import 'mueve_colors.dart';

class AppThemes {
  // Tema claro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'SF Pro Display',
    
    // Colores principales
    colorScheme: ColorScheme.fromSeed(
      seedColor: MueveColors.brightOrange,
      brightness: Brightness.light,
      primary: MueveColors.brightOrange,
      secondary: MueveColors.skyBlue,
      surface: MueveColors.pureWhite,
      background: MueveColors.lightGray,
      error: MueveColors.error,
    ),
    
    // Scaffold
    scaffoldBackgroundColor: MueveColors.lightGray,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: MueveColors.darkNavy,
      foregroundColor: MueveColors.pureWhite,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: MueveColors.pureWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'SF Pro Display',
      ),
    ),
    
    // Botones elegantes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B73FF), // Azul suave consistente
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF6B73FF).withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Display',
        ),
      ),
    ),
    
    // Campos de texto estilo cartón elegante
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8F9FA), // Gris muy claro
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, // Sin borde para look más limpio
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6B73FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: Color(0xFF6C757D)),
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    ),
    
    // Cards estilo cartón
    cardTheme: CardThemeData(
      color: MueveColors.pureWhite,
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
  
  // Tema oscuro elegante
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'SF Pro Display',
    
    // Colores principales suaves
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B73FF), // Azul suave en lugar de naranja chillón
      brightness: Brightness.dark,
      primary: const Color(0xFF6B73FF),
      secondary: const Color(0xFF9C88FF),
      surface: const Color(0xFF2A2D3A), // Gris azulado suave
      background: const Color(0xFF1F2128), // Fondo muy suave
      error: const Color(0xFFFF6B6B), // Rojo suave
      onSurface: const Color(0xFFE1E3E6), // Texto claro pero no blanco puro
      onBackground: const Color(0xFFE1E3E6),
    ),
    
    // Scaffold con fondo suave
    scaffoldBackgroundColor: const Color(0xFF1F2128),
    
    // AppBar elegante
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF2A2D3A),
      foregroundColor: Color(0xFFE1E3E6),
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: Color(0xFFE1E3E6),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'SF Pro Display',
      ),
    ),
    
    // Botones elegantes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B73FF), // Azul suave
        foregroundColor: Colors.white,
        elevation: 2,
        shadowColor: const Color(0xFF6B73FF).withOpacity(0.3),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'SF Pro Display',
        ),
      ),
    ),
    
    // Campos de texto estilo cartón elegante
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2D3A), // Mismo color que surface
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none, // Sin borde para look más limpio
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6B73FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: const TextStyle(color: Color(0xFFB0B3B8)),
      hintStyle: const TextStyle(color: Color(0xFF8B8E93)),
    ),
    
    // Cards estilo cartón
    cardTheme: CardThemeData(
      color: const Color(0xFF2A2D3A),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
}
