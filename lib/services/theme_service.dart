import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeService extends ChangeNotifier {
  static const _storage = FlutterSecureStorage();
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.light;
  
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  // Singleton
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();
  
  /// Inicializar el tema desde storage
  Future<void> initTheme() async {
    try {
      final savedTheme = await _storage.read(key: _themeKey);
      if (savedTheme != null) {
        _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error cargando tema: $e');
    }
  }
  
  /// Cambiar tema
  Future<void> toggleTheme() async {
    try {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      await _storage.write(key: _themeKey, value: _themeMode == ThemeMode.dark ? 'dark' : 'light');
      notifyListeners();
      debugPrint('🎨 Tema cambiado a: ${_themeMode == ThemeMode.dark ? 'Oscuro' : 'Claro'}');
    } catch (e) {
      debugPrint('Error guardando tema: $e');
    }
  }
  
  /// Establecer tema específico
  Future<void> setTheme(ThemeMode mode) async {
    try {
      _themeMode = mode;
      await _storage.write(key: _themeKey, value: mode == ThemeMode.dark ? 'dark' : 'light');
      notifyListeners();
    } catch (e) {
      debugPrint('Error estableciendo tema: $e');
    }
  }
}
