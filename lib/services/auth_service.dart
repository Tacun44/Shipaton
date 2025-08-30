import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cuenta_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';

  // Verificar si el usuario está autenticado
  static Future<bool> isLoggedIn() async {
    try {
      final isLoggedIn = await _storage.read(key: _keyIsLoggedIn);
      return isLoggedIn == 'true';
    } catch (error) {
      debugPrint('❌ Error al verificar autenticación: $error');
      return false;
    }
  }

  // Iniciar sesión SIMPLE con usuario mock
  static Future<AuthResult> login(String email, String password) async {
    try {
      debugPrint('🔐 Login simple: $email');

      // Simular delay de autenticación
      await Future.delayed(const Duration(milliseconds: 500));

      // Validación SIMPLE: admin@gmail.com/123456
      if (email.toLowerCase() == 'admin@gmail.com' && password == '123456') {
        // Guardar en storage local
        await _storage.write(key: _keyIsLoggedIn, value: 'true');
        await _storage.write(key: _keyUserId, value: 'admin_001');
        await _storage.write(key: _keyUserName, value: 'Administrador');

        debugPrint('✅ Login exitoso - admin@gmail.com/123456');

        return AuthResult(
          success: true,
          message: '¡Bienvenido Administrador!',
          user: CuentaModel(
            id: 'admin_001',
            nombreUsuario: 'Administrador',
            saldoPrincipal: 25750.50,
            saldoAhorros: 12200.00,
            limiteTarjeta: 75000.00,
            saldoUtilizado: 8500.00,
            ultimosMovimientos: [],
            ultimaActualizacion: DateTime.now(),
          ),
        );
      }

      return AuthResult(
        success: false,
        message: 'Credenciales incorrectas. Usa: admin@gmail.com/123456',
      );
    } catch (error) {
      debugPrint('❌ Error en login: $error');
      return AuthResult(
        success: false,
        message: 'Error de conexión. Intenta de nuevo.',
      );
    }
  }

  // Cerrar sesión
  static Future<void> logout() async {
    try {
      // Limpiar storage local
      await _storage.delete(key: _keyIsLoggedIn);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserName);
      debugPrint('✅ Sesión cerrada');
    } catch (error) {
      debugPrint('❌ Error al cerrar sesión: $error');
    }
  }

  // Método signIn para compatibilidad con pantallas existentes
  static Future<void> signIn(
      {required String email, required String password}) async {
    final result = await login(email, password);
    if (!result.success) {
      throw Exception(result.message);
    }
  }

  // Método signUp para registro
  static Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 800));

      debugPrint('✅ Usuario registrado: $fullName ($email)');
    } catch (error) {
      throw Exception('Error al crear cuenta: $error');
    }
  }

  // Método resetPassword para recuperación
  static Future<void> resetPassword(String email) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint('✅ Email de recuperación enviado a: $email');
    } catch (error) {
      throw Exception('Error al enviar email de recuperación: $error');
    }
  }
}

class AuthResult {
  final bool success;
  final String message;
  final CuentaModel? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}
