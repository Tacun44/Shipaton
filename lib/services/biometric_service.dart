import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'auth_service.dart';

class BiometricService {
  static const _storage = FlutterSecureStorage();
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  // Claves para almacenamiento seguro
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _userEmailKey = 'user_email';
  static const String _userPasswordKey = 'user_password';

  /// Verificar si el dispositivo soporta biometría
  static Future<bool> isDeviceSupported() async {
    try {
      // En web, la biometría no está soportada
      if (kIsWeb) return false;
      
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      debugPrint('Error verificando soporte biométrico: $e');
      return false;
    }
  }

  /// Verificar si hay biometría disponible (configurada)
  static Future<bool> isBiometricAvailable() async {
    try {
      final isSupported = await isDeviceSupported();
      if (!isSupported) return false;

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando disponibilidad biométrica: $e');
      return false;
    }
  }

  /// Obtener tipos de biometría disponibles
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      // En web, no hay biometría disponible
      if (kIsWeb) return [];
      
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error obteniendo tipos biométricos: $e');
      return [];
    }
  }

  /// Verificar si la biometría está habilitada para este usuario
  static Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _storage.read(key: _biometricEnabledKey);
      return enabled == 'true';
    } catch (e) {
      debugPrint('Error verificando si biometría está habilitada: $e');
      return false;
    }
  }

  /// Autenticar con biometría
  static Future<bool> authenticateWithBiometric({
    String? customMessage,
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometría no disponible en este dispositivo');
      }

      final availableBiometrics = await getAvailableBiometrics();
      String message = customMessage ?? _getBiometricMessage(availableBiometrics);

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: message,
        options: const AuthenticationOptions(
          biometricOnly: false, // Permite PIN/patrón como respaldo
          stickyAuth: true,
        ),
      );

      return didAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error en autenticación biométrica: ${e.message}');
      
      // Manejar errores específicos
      switch (e.code) {
        case 'NotAvailable':
          throw Exception('Biometría no disponible');
        case 'NotEnrolled':
          throw Exception('No hay biometría configurada. Ve a Configuración para configurarla.');
        case 'LockedOut':
          throw Exception('Biometría bloqueada temporalmente. Usa tu PIN o contraseña.');
        case 'PermanentlyLockedOut':
          throw Exception('Biometría bloqueada permanentemente. Usa tu PIN o contraseña.');
        default:
          throw Exception('Error de autenticación: ${e.message}');
      }
    } catch (e) {
      debugPrint('Error inesperado en biometría: $e');
      throw Exception('Error inesperado: $e');
    }
  }

  /// Configurar biometría para el usuario actual (guardar credenciales)
  static Future<bool> setupBiometricAuth({
    required String email,
    required String password,
  }) async {
    try {
      // Verificar que la biometría esté disponible
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometría no disponible en este dispositivo');
      }

      // Autenticar con biometría para confirmar
      final authenticated = await authenticateWithBiometric(
        customMessage: 'Confirma tu identidad para habilitar acceso rápido',
      );

      if (!authenticated) {
        return false;
      }

      // Guardar credenciales de forma segura
      await _storage.write(key: _userEmailKey, value: email);
      await _storage.write(key: _userPasswordKey, value: password);
      await _storage.write(key: _biometricEnabledKey, value: 'true');

      return true;
    } catch (e) {
      debugPrint('Error configurando biometría: $e');
      rethrow;
    }
  }

  /// Iniciar sesión con biometría
  static Future<bool> signInWithBiometric() async {
    try {
      // Verificar que la biometría esté habilitada
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        throw Exception('Biometría no configurada para este usuario');
      }

      // Autenticar con biometría
      final authenticated = await authenticateWithBiometric(
        customMessage: 'Usa tu huella o Face ID para iniciar sesión',
      );

      if (!authenticated) {
        return false;
      }

      // Obtener credenciales guardadas
      final email = await _storage.read(key: _userEmailKey);
      final password = await _storage.read(key: _userPasswordKey);

      if (email == null || password == null) {
        throw Exception('Credenciales no encontradas. Inicia sesión normalmente.');
      }

      // Iniciar sesión con Supabase
      await AuthService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      debugPrint('Error en login biométrico: $e');
      rethrow;
    }
  }

  /// Deshabilitar biometría (eliminar credenciales guardadas)
  static Future<void> disableBiometric() async {
    try {
      await _storage.delete(key: _userEmailKey);
      await _storage.delete(key: _userPasswordKey);
      await _storage.delete(key: _biometricEnabledKey);
    } catch (e) {
      debugPrint('Error deshabilitando biometría: $e');
    }
  }

  /// Verificar si hay credenciales guardadas para biometría
  static Future<String?> getSavedEmail() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return null;
      
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      debugPrint('Error obteniendo email guardado: $e');
      return null;
    }
  }

  /// Obtener mensaje apropiado según el tipo de biometría disponible
  static String _getBiometricMessage(List<BiometricType> availableBiometrics) {
    if (availableBiometrics.contains(BiometricType.face)) {
      return 'Usa Face ID para iniciar sesión';
    } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
      return 'Usa tu huella dactilar para iniciar sesión';
    } else if (availableBiometrics.contains(BiometricType.iris)) {
      return 'Usa reconocimiento de iris para iniciar sesión';
    } else {
      return 'Usa tu autenticación biométrica para iniciar sesión';
    }
  }

  /// Obtener nombre del tipo de biometría disponible
  static Future<String> getBiometricTypeName() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Huella Dactilar';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Reconocimiento de Iris';
      } else {
        return 'Biometría';
      }
    } catch (e) {
      return 'Biometría';
    }
  }
}
