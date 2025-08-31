import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/cuenta_model.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';

  // Cliente de Supabase
  static SupabaseClient get _supabase => Supabase.instance.client;

  // Verificar si el usuario está autenticado
  static Future<bool> isLoggedIn() async {
    try {
      // Verificar sesión de Supabase primero
      final session = _supabase.auth.currentSession;
      if (session != null) {
        debugPrint('✅ Sesión activa en Supabase para: ${session.user.email}');
        return true;
      }

      // Fallback a storage local
      final isLoggedIn = await _storage.read(key: _keyIsLoggedIn);
      final userId = await _storage.read(key: _keyUserId);
      
      debugPrint('🔍 Storage local - isLoggedIn: $isLoggedIn, userId: $userId');
      
      // Solo considerar autenticado si ambos valores existen
      if (isLoggedIn == 'true' && userId != null && userId.isNotEmpty) {
        debugPrint('✅ Usuario autenticado localmente: $userId');
        return true;
      }
      
      debugPrint('❌ No hay sesión activa');
      return false;
    } catch (error) {
      debugPrint('❌ Error al verificar autenticación: $error');
      return false;
    }
  }

  // Iniciar sesión con Supabase Auth REAL
  static Future<AuthResult> login(String email, String password) async {
    try {
      debugPrint('🔐 Login con Supabase: $email');

      // Intentar autenticación con Supabase Auth
      try {
        final response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (response.user != null) {
          debugPrint('✅ Login exitoso en Supabase: ${response.user!.email}');

          // Guardar en storage local también
          await _storage.write(key: _keyIsLoggedIn, value: 'true');
          await _storage.write(key: _keyUserId, value: response.user!.id);
          await _storage.write(
              key: _keyUserName, value: response.user!.email!.split('@')[0]);

          // Obtener datos reales de la cuenta
          final cuentaData = await _supabase
              .from('cuentas')
              .select()
              .eq('user_id', response.user!.id)
              .maybeSingle();

          if (cuentaData != null) {
            debugPrint('✅ Cuenta encontrada: ${cuentaData['nombre_usuario']}');

            return AuthResult(
              success: true,
              message: '¡Bienvenido ${cuentaData['nombre_usuario']}!',
              user: CuentaModel(
                id: response.user!.id,
                nombreUsuario: cuentaData['nombre_usuario'],
                saldoPrincipal: double.tryParse(
                        cuentaData['saldo_principal']?.toString() ?? '0') ??
                    0.0,
                saldoAhorros: double.tryParse(
                        cuentaData['saldo_ahorros']?.toString() ?? '0') ??
                    0.0,
                limiteTarjeta: double.tryParse(
                        cuentaData['limite_tarjeta']?.toString() ?? '0') ??
                    0.0,
                saldoUtilizado: double.tryParse(
                        cuentaData['saldo_utilizado']?.toString() ?? '0') ??
                    0.0,
                ultimosMovimientos: [],
                ultimaActualizacion: DateTime.now(),
              ),
            );
          } else {
            debugPrint('⚠️ No se encontró cuenta, creando una nueva...');
            // Crear cuenta automáticamente si no existe
            await _supabase.from('cuentas').insert({
              'user_id': response.user!.id,
              'nombre_usuario': response.user!.email!.split('@')[0],
              'saldo_principal': 0.00,
              'saldo_ahorros': 0.00,
              'limite_tarjeta': 5000.00,
              'saldo_utilizado': 0.00,
            });

            return AuthResult(
              success: true,
              message: '¡Bienvenido! Cuenta creada.',
              user: CuentaModel(
                id: response.user!.id,
                nombreUsuario: response.user!.email!.split('@')[0],
                saldoPrincipal: 0.0,
                saldoAhorros: 0.0,
                limiteTarjeta: 5000.0,
                saldoUtilizado: 0.0,
                ultimosMovimientos: [],
                ultimaActualizacion: DateTime.now(),
              ),
            );
          }
        }
      } catch (supabaseError) {
        debugPrint('⚠️ Error de Supabase: $supabaseError');

        // Fallback: validación local para desarrollo
        if (email.toLowerCase() == 'admin@gmail.com' && password == '123456') {
          await _storage.write(key: _keyIsLoggedIn, value: 'true');
          await _storage.write(key: _keyUserId, value: 'admin_local');
          await _storage.write(key: _keyUserName, value: 'Admin Local');

          return AuthResult(
            success: true,
            message: '¡Bienvenido Admin! (Modo Local)',
            user: CuentaModel(
              id: 'admin_local',
              nombreUsuario: 'Admin Local',
              saldoPrincipal: 25750.50,
              saldoAhorros: 12200.00,
              limiteTarjeta: 75000.00,
              saldoUtilizado: 8500.00,
              ultimosMovimientos: [],
              ultimaActualizacion: DateTime.now(),
            ),
          );
        }
      }

      return AuthResult(
        success: false,
        message:
            'Credenciales incorrectas. Prueba: jhonjairoravelomora@gmail.com / 123456',
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
      // Cerrar sesión en Supabase Auth
      try {
        await _supabase.auth.signOut();
        debugPrint('✅ Sesión cerrada en Supabase');
      } catch (supabaseError) {
        debugPrint('⚠️ Error al cerrar sesión en Supabase: $supabaseError');
      }

      // Limpiar storage local siempre
      await _storage.delete(key: _keyIsLoggedIn);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserName);
      debugPrint('✅ Storage local limpiado');
    } catch (error) {
      debugPrint('❌ Error al cerrar sesión: $error');
    }
  }

  // Limpiar completamente el estado de autenticación (para debugging)
  static Future<void> clearAuthState() async {
    try {
      debugPrint('🧹 Limpiando completamente el estado de autenticación...');
      
      // Cerrar sesión en Supabase
      try {
        await _supabase.auth.signOut();
      } catch (e) {
        debugPrint('⚠️ Error cerrando sesión Supabase: $e');
      }
      
      // Limpiar todo el storage
      await _storage.deleteAll();
      
      debugPrint('✅ Estado de autenticación completamente limpiado');
    } catch (error) {
      debugPrint('❌ Error limpiando estado: $error');
    }
  }

  // Obtener usuario actual desde Supabase
  static User? getCurrentUser() {
    try {
      return _supabase.auth.currentUser;
    } catch (error) {
      debugPrint('⚠️ Error al obtener usuario actual: $error');
      return null;
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

  // Validar formato de email
  static bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  // Método signUp para registro con Supabase
  static Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      debugPrint('🚀 INICIANDO REGISTRO');
      debugPrint('📧 Email: $email');
      debugPrint('🔒 Password length: ${password.length}');
      debugPrint('👤 Full name: $fullName');
      
      // Validar email antes de enviar a Supabase
      if (!_isValidEmail(email)) {
        debugPrint('❌ Email inválido: $email');
        throw Exception('El formato del email no es válido. Ejemplo: usuario@gmail.com');
      }
      debugPrint('✅ Email válido');

      // Validar contraseña
      if (password.length < 6) {
        debugPrint('❌ Contraseña muy corta: ${password.length} caracteres');
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      }
      debugPrint('✅ Contraseña válida');

      // Validar nombre
      if (fullName.trim().isEmpty) {
        debugPrint('❌ Nombre vacío');
        throw Exception('El nombre completo es requerido');
      }
      debugPrint('✅ Nombre válido');

      debugPrint('📝 Enviando registro a Supabase: $email');

      // Registrar en Supabase Auth
      debugPrint('🔄 Llamando a Supabase Auth...');
      final response = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'full_name': fullName.trim()},
      );

      debugPrint('📨 Respuesta de Supabase recibida');
      debugPrint('👤 Usuario creado: ${response.user != null}');
      debugPrint('📧 Email confirmado: ${response.user?.emailConfirmedAt != null}');

      if (response.user != null) {
        debugPrint('✅ Usuario registrado en Supabase Auth: ${response.user!.id}');

        // Crear perfil automáticamente
        debugPrint('🔄 Creando perfil...');
        try {
          await _supabase.from('profiles').insert({
            'id': response.user!.id,
            'email': email.trim().toLowerCase(),
            'full_name': fullName.trim(),
          });
          debugPrint('✅ Perfil creado exitosamente');
        } catch (profileError) {
          debugPrint('⚠️ Error creando perfil: $profileError');
        }

        // Crear cuenta inicial automáticamente
        debugPrint('🔄 Creando cuenta inicial...');
        try {
          await _supabase.from('cuentas').insert({
            'user_id': response.user!.id,
            'nombre_usuario': fullName.trim(),
            'saldo_principal': 0.00,
            'saldo_ahorros': 0.00,
            'limite_tarjeta': 5000.00,
            'saldo_utilizado': 0.00,
          });
          debugPrint('✅ Cuenta inicial creada exitosamente');
        } catch (cuentaError) {
          debugPrint('⚠️ Error creando cuenta: $cuentaError');
        }

        debugPrint('🎉 REGISTRO COMPLETADO EXITOSAMENTE para: $fullName');
      } else {
        debugPrint('❌ No se recibió usuario en la respuesta');
        throw Exception('No se pudo crear el usuario. Verifica tu conexión a internet.');
      }
    } catch (error) {
      debugPrint('❌ Error en registro: $error');
      
      // Mejorar mensajes de error específicos
      String errorMessage = error.toString();
      
      if (errorMessage.contains('email_address_invalid')) {
        throw Exception('El formato del email no es válido. Usa un email real como: usuario@gmail.com');
      } else if (errorMessage.contains('User already registered')) {
        throw Exception('Este email ya está registrado. Intenta iniciar sesión.');
      } else if (errorMessage.contains('Password should be at least')) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      } else if (errorMessage.contains('Invalid email')) {
        throw Exception('Email inválido. Usa un formato como: usuario@gmail.com');
      } else {
        throw Exception('Error al crear cuenta: Verifica tu conexión e intenta con un email válido');
      }
    }
  }

  // Método resetPassword para recuperación con Supabase
  static Future<void> resetPassword(String email) async {
    try {
      debugPrint('📧 Enviando email de recuperación: $email');

      // Enviar email de recuperación con Supabase Auth
      await _supabase.auth.resetPasswordForEmail(email);

      debugPrint('✅ Email de recuperación enviado');
    } catch (error) {
      debugPrint('❌ Error al enviar email de recuperación: $error');
      throw Exception('Error al enviar email: ${error.toString()}');
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
