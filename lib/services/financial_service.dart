import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/cuenta_model.dart';

class FinancialService {
  static final SupabaseClient _client = SupabaseConfig.client;

  // Obtener cuenta principal del usuario
  static Future<CuentaModel?> obtenerCuentaPrincipal() async {
    try {
      final response = await _client
          .from('cuentas')
          .select()
          .limit(1)
          .single();
      
      return CuentaModel.fromJson(response);
    } catch (error) {
      print('❌ Error al obtener cuenta: $error');
      return null;
    }
  }

  // Obtener movimientos recientes
  static Future<List<MovimientoModel>> obtenerMovimientosRecientes({int limit = 10}) async {
    try {
      final response = await _client
          .from('movimientos')
          .select()
          .order('fecha', ascending: false)
          .limit(limit);
      
      return response.map((json) => MovimientoModel.fromJson(json)).toList();
    } catch (error) {
      print('❌ Error al obtener movimientos: $error');
      return [];
    }
  }

  // Agregar nuevo movimiento
  static Future<bool> agregarMovimiento({
    required String descripcion,
    required double monto,
    required TipoMovimiento tipo,
    String? categoria,
  }) async {
    try {
      // Obtener ID de cuenta principal
      final cuenta = await obtenerCuentaPrincipal();
      if (cuenta == null) return false;

      await _client.from('movimientos').insert({
        'cuenta_id': cuenta.id,
        'descripcion': descripcion,
        'monto': monto,
        'tipo': tipo.toString().split('.').last,
        'categoria': categoria,
      });

      // Actualizar saldo de la cuenta
      await _actualizarSaldoCuenta(cuenta.id, monto, tipo);
      
      return true;
    } catch (error) {
      print('❌ Error al agregar movimiento: $error');
      return false;
    }
  }

  // Actualizar saldo de cuenta
  static Future<void> _actualizarSaldoCuenta(String cuentaId, double monto, TipoMovimiento tipo) async {
    try {
      final cuenta = await obtenerCuentaPrincipal();
      if (cuenta == null) return;

      double nuevoSaldo = cuenta.saldoPrincipal;
      
      switch (tipo) {
        case TipoMovimiento.ingreso:
        case TipoMovimiento.transferencia:
          nuevoSaldo += monto.abs();
          break;
        case TipoMovimiento.gasto:
        case TipoMovimiento.pago:
          nuevoSaldo -= monto.abs();
          break;
      }

      await _client
          .from('cuentas')
          .update({
            'saldo_principal': nuevoSaldo,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', cuentaId);
          
    } catch (error) {
      print('❌ Error al actualizar saldo: $error');
    }
  }

  // Recargar fondos a la cuenta
  static Future<bool> recargarFondos(double monto) async {
    return await agregarMovimiento(
      descripcion: 'Recarga de fondos',
      monto: monto,
      tipo: TipoMovimiento.ingreso,
      categoria: 'Recarga',
    );
  }

  // Simular pago o transferencia
  static Future<bool> realizarTransferencia({
    required double monto,
    required String destinatario,
  }) async {
    return await agregarMovimiento(
      descripcion: 'Transferencia a $destinatario',
      monto: -monto,
      tipo: TipoMovimiento.transferencia,
      categoria: 'Transferencias',
    );
  }
}
