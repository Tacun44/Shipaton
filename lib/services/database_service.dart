import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class DatabaseService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Insertar registro en la tabla prueba
  static Future<Map<String, dynamic>?> insertarRegistroPrueba() async {
    try {
      final response = await _client
          .from('prueba')
          .insert({})
          .select()
          .single();
      
      debugPrint('✅ Registro insertado: $response');
      return response;
    } catch (error) {
      debugPrint('❌ Error al insertar: $error');
      return null;
    }
  }

  // Obtener todos los registros de la tabla prueba
  static Future<List<Map<String, dynamic>>> obtenerRegistrosPrueba() async {
    try {
      final response = await _client
          .from('prueba')
          .select()
          .order('id', ascending: true);
      
      debugPrint('✅ Registros obtenidos: ${response.length}');
      return response;
    } catch (error) {
      debugPrint('❌ Error al obtener registros: $error');
      return [];
    }
  }

  // Contar registros en la tabla prueba
  static Future<int> contarRegistros() async {
    try {
      final response = await _client
          .from('prueba')
          .select()
          .count();
      
      return response.count;
    } catch (error) {
      debugPrint('❌ Error al contar registros: $error');
      return 0;
    }
  }
}
