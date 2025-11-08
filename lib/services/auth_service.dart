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
            // Crear cuenta automáticamente si no existe con saldo demo y wallet
            final walletId = 'wallet_${response.user!.id}_${DateTime.now().millisecondsSinceEpoch}';
            
            await _supabase.from('cuentas').insert({
              'user_id': response.user!.id,
              'nombre_usuario': response.user!.email!.split('@')[0],
              'saldo_principal': 15750.50, // Saldo demo inicial
              'saldo_ahorros': 8200.00,
              'limite_tarjeta': 50000.00,
              'saldo_utilizado': 2500.00,
              'wallet_id': walletId, // Wallet único para cada cuenta
            });

            return AuthResult(
              success: true,
              message: '¡Bienvenido! Cuenta creada con saldo demo.',
              user: CuentaModel(
                id: response.user!.id,
                nombreUsuario: response.user!.email!.split('@')[0],
                saldoPrincipal: 15750.50, // Saldo demo inicial
                saldoAhorros: 8200.00,
                limiteTarjeta: 50000.00,
                saldoUtilizado: 2500.00,
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

        // Verificar si hay usuario local registrado
        final localEmail = await _storage.read(key: 'local_email');
        final localPassword = await _storage.read(key: 'local_password');
        final localUserId = await _storage.read(key: _keyUserId);
        final localUserName = await _storage.read(key: _keyUserName);

        if (localEmail != null && 
            localPassword != null && 
            email.toLowerCase() == localEmail.toLowerCase() && 
            password == localPassword) {
          
          debugPrint('✅ Login exitoso con usuario local: $localEmail');
          
          await _storage.write(key: _keyIsLoggedIn, value: 'true');

          return AuthResult(
            success: true,
            message: '¡Bienvenido ${localUserName ?? 'Usuario'}! (Modo Demo)',
            user: CuentaModel(
              id: localUserId ?? 'local_user',
              nombreUsuario: localUserName ?? 'Usuario Demo',
              saldoPrincipal: 15750.50,
              saldoAhorros: 8200.00,
              limiteTarjeta: 50000.00,
              saldoUtilizado: 2500.00,
              ultimosMovimientos: [],
              ultimaActualizacion: DateTime.now(),
            ),
          );
        }
      }

      return AuthResult(
        success: false,
        message:
            'Credenciales incorrectas. Registra una cuenta nueva o prueba: admin@gmail.com / 123456',
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

  // Validar formato de email (modo demo - súper permisivo)
  static bool _isValidEmail(String email) {
    // Modo demo: acepta cualquier email que tenga @ (súper permisivo)
    final emailTrimmed = email.trim();
    return emailTrimmed.contains('@') && emailTrimmed.length > 3;
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
      
      // Validar email antes de enviar a Supabase (modo demo súper permisivo)
      if (!_isValidEmail(email)) {
        debugPrint('❌ Email inválido: $email');
        throw Exception('El email debe contener @ (ej: juan@demo)');
      }
      debugPrint('✅ Email válido (modo demo súper permisivo)');

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
      
      AuthResponse? response;
      bool isLocalFallback = false;
      
      try {
        response = await _supabase.auth.signUp(
          email: email.trim().toLowerCase(),
          password: password,
          data: {'full_name': fullName.trim()},
        );
      } catch (supabaseError) {
        debugPrint('⚠️ Supabase rechazó el email, usando fallback local');
        debugPrint('🔄 Error de Supabase: $supabaseError');
        
        // Crear usuario local para demo
        isLocalFallback = true;
        final localUserId = 'local_${DateTime.now().millisecondsSinceEpoch}';
        
        // Guardar en storage local
        await _storage.write(key: _keyIsLoggedIn, value: 'true');
        await _storage.write(key: _keyUserId, value: localUserId);
        await _storage.write(key: _keyUserName, value: fullName.trim());
        await _storage.write(key: 'local_email', value: email.trim().toLowerCase());
        await _storage.write(key: 'local_password', value: password);
        
        debugPrint('✅ Usuario local creado: $localUserId');
      }

      if (isLocalFallback) {
        debugPrint('🎉 REGISTRO LOCAL COMPLETADO EXITOSAMENTE para: $fullName');
        return; // Salir exitosamente
      }

      debugPrint('📨 Respuesta de Supabase recibida');
      debugPrint('👤 Usuario creado: ${response?.user != null}');
      debugPrint('📧 Email confirmado: ${response?.user?.emailConfirmedAt != null}');

      if (response?.user != null) {
        debugPrint('✅ Usuario registrado en Supabase Auth: ${response!.user!.id}');

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
        throw Exception('Formato de email inválido. Prueba con: juan@demo.com');
      } else if (errorMessage.contains('User already registered')) {
        throw Exception('Este email ya está registrado. Intenta iniciar sesión.');
      } else if (errorMessage.contains('Password should be at least')) {
        throw Exception('La contraseña debe tener al menos 6 caracteres');
      } else if (errorMessage.contains('Invalid email')) {
        throw Exception('Email inválido. Formato: algo@algo.algo (ej: test@demo.com)');
      } else {
        throw Exception('Error al crear cuenta: Intenta con formato juan@demo.com');
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
