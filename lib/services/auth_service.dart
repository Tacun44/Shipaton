import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Obtener usuario actual
  static User? get currentUser => _client.auth.currentUser;

  // Verificar si el usuario está autenticado
  static bool get isAuthenticated => currentUser != null;

  // Stream para escuchar cambios de autenticación
  static Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Registrar usuario
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Iniciar sesión con callback para configuración biométrica
  static Future<AuthResponse> signInWithBiometricSetup({
    required String email,
    required String password,
    Function(String email, String password)? onFirstLogin,
  }) async {
    try {
      final response = await signIn(email: email, password: password);
      
      // Si el login fue exitoso y hay callback, ejecutarlo
      if (response.user != null && onFirstLogin != null) {
        onFirstLogin(email, password);
      }
      
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Cerrar sesión
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Restablecer contraseña
  static Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Obtener perfil del usuario
  static Future<Map<String, dynamic>?> getUserProfile() async {
    try {
      if (!isAuthenticated) return null;
      
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();
      
      return response;
    } catch (e) {
      return null;
    }
  }

  // Actualizar perfil del usuario
  static Future<void> updateUserProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      if (!isAuthenticated) throw Exception('Usuario no autenticado');

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (fullName != null) updates['full_name'] = fullName;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _client
          .from('profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (e) {
      rethrow;
    }
  }
}
