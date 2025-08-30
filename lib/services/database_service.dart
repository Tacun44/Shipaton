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
      
      print('✅ Registro insertado: $response');
      return response;
    } catch (error) {
      print('❌ Error al insertar: $error');
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
      
      print('✅ Registros obtenidos: ${response.length}');
      return response;
    } catch (error) {
      print('❌ Error al obtener registros: $error');
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
      print('❌ Error al contar registros: $error');
      return 0;
    }
  }
}
