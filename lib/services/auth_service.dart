import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/cuenta_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';

  // Simular usuarios predeterminados (en producción esto vendría de Supabase)
  static final Map<String, Map<String, String>> _usuarios = {
    'admin@mueve.com': {
      'password': '123456',
      'name': 'Juan Pérez',
      'id': 'user_001',
    },
    'demo@mueve.com': {
      'password': 'demo123',
      'name': 'María González',
      'id': 'user_002',
    },
    'test@mueve.com': {
      'password': 'test123',
      'name': 'Carlos López',
      'id': 'user_003',
    },
  };

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

  // Iniciar sesión
  static Future<AuthResult> login(String email, String password) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 1500));

      // Verificar credenciales
      if (_usuarios.containsKey(email.toLowerCase())) {
        final userData = _usuarios[email.toLowerCase()]!;
        if (userData['password'] == password) {
          // Guardar estado de autenticación
          await _storage.write(key: _keyIsLoggedIn, value: 'true');
          await _storage.write(key: _keyUserId, value: userData['id']!);
          await _storage.write(key: _keyUserName, value: userData['name']!);
          
          return AuthResult(
            success: true,
            message: '¡Bienvenido de vuelta!',
            user: CuentaModel(
              id: userData['id']!,
              nombreUsuario: userData['name']!,
              saldoPrincipal: 15750.50,
              saldoAhorros: 8200.00,
              limiteTarjeta: 50000.00,
              saldoUtilizado: 12500.00,
              ultimosMovimientos: [],
              ultimaActualizacion: DateTime.now(),
            ),
          );
        }
      }
      
      return AuthResult(
        success: false,
        message: 'Email o contraseña incorrectos',
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
      await _storage.delete(key: _keyIsLoggedIn);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserName);
    } catch (error) {
      debugPrint('❌ Error al cerrar sesión: $error');
    }
  }

  // Obtener datos del usuario guardados
  static Future<Map<String, String?>> getUserData() async {
    try {
      final userId = await _storage.read(key: _keyUserId);
      final userName = await _storage.read(key: _keyUserName);
      
      return {
        'id': userId,
        'name': userName,
      };
    } catch (error) {
      debugPrint('❌ Error al obtener datos del usuario: $error');
      return {'id': null, 'name': null};
    }
  }

  // Obtener lista de usuarios demo (para facilitar las pruebas)
  static List<Map<String, String>> getDemoUsers() {
    return _usuarios.entries.map((entry) => {
      'email': entry.key,
      'password': entry.value['password']!,
      'name': entry.value['name']!,
    }).toList();
  }

  // Método signIn para compatibilidad con pantallas existentes
  static Future<void> signIn({required String email, required String password}) async {
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
      await Future.delayed(const Duration(milliseconds: 1500));
      
      // Verificar si el email ya existe
      if (_usuarios.containsKey(email.toLowerCase())) {
        throw Exception('Este email ya está registrado');
      }
      
      // En una app real, esto se haría con Supabase
      // Por ahora solo simulamos el registro exitoso
      debugPrint('✅ Usuario registrado: $fullName ($email)');
      
    } catch (error) {
      throw Exception('Error al crear cuenta: $error');
    }
  }

  // Método resetPassword para recuperación
  static Future<void> resetPassword(String email) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // En una app real, esto enviaría un email con Supabase
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