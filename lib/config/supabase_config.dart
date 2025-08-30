import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // URL de tu proyecto Supabase
  static const String supabaseUrl = 'https://tycabutsaykxvuhfctpg.supabase.co';

  // Clave anónima de tu proyecto
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR5Y2FidXRzYXlreHZ1aGZjdHBnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY1NjQ0MzEsImV4cCI6MjA3MjE0MDQzMX0.R69i_Z7fwB8oF3V_hISucUQtdDES-xpbrSMKV9J5rUY';

  // Inicializar Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: true,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
      );
      print('✅ Supabase inicializado correctamente');
    } catch (error) {
      print('❌ Error al inicializar Supabase: $error');
      print('🔄 Continuando en modo offline...');
      // No rethrow - permitir que la app continúe
    }
  }

  // Obtener cliente de Supabase
  static SupabaseClient get client => Supabase.instance.client;
}
