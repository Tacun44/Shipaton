import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class WalletService {
  static final SupabaseClient _supabase = SupabaseConfig.client;

  /// Agregar fondos al wallet del usuario después de una compra exitosa
  static Future<bool> agregarFondos({
    required String userId,
    required double cantidad,
    required String concepto,
    String? transactionId,
  }) async {
    try {
      debugPrint('💰 Agregando fondos: \$${cantidad.toStringAsFixed(2)} para usuario: $userId');
      
      // Obtener la cuenta actual del usuario
      final cuentaResponse = await _supabase
          .from('cuentas')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (cuentaResponse == null) {
        debugPrint('❌ No se encontró cuenta para el usuario: $userId');
        return false;
      }

      final saldoActual = double.tryParse(cuentaResponse['saldo_principal']?.toString() ?? '0') ?? 0.0;
      final nuevoSaldo = saldoActual + cantidad;

      // Actualizar el saldo en la cuenta
      await _supabase
          .from('cuentas')
          .update({
            'saldo_principal': nuevoSaldo,
            'ultima_actualizacion': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId);

      // Registrar el movimiento en el historial
      await _registrarMovimiento(
        userId: userId,
        tipo: 'recarga',
        cantidad: cantidad,
        concepto: concepto,
        transactionId: transactionId,
      );

      debugPrint('✅ Fondos agregados exitosamente. Nuevo saldo: \$${nuevoSaldo.toStringAsFixed(2)}');
      return true;
    } catch (error) {
      debugPrint('❌ Error agregando fondos: $error');
      return false;
    }
  }

  /// Obtener el saldo actual del usuario
  static Future<double> obtenerSaldo(String userId) async {
    try {
      final cuentaResponse = await _supabase
          .from('cuentas')
          .select('saldo_principal')
          .eq('user_id', userId)
          .maybeSingle();

      if (cuentaResponse == null) {
        debugPrint('❌ No se encontró cuenta para obtener saldo');
        return 0.0;
      }

      final saldo = double.tryParse(cuentaResponse['saldo_principal']?.toString() ?? '0') ?? 0.0;
      debugPrint('💰 Saldo actual: \$${saldo.toStringAsFixed(2)}');
      return saldo;
    } catch (error) {
      debugPrint('❌ Error obteniendo saldo: $error');
      return 0.0;
    }
  }

  /// Obtener el wallet ID del usuario
  static Future<String?> obtenerWalletId(String userId) async {
    try {
      final cuentaResponse = await _supabase
          .from('cuentas')
          .select('wallet_id')
          .eq('user_id', userId)
          .maybeSingle();

      if (cuentaResponse == null) {
        debugPrint('❌ No se encontró wallet para el usuario');
        return null;
      }

      final walletId = cuentaResponse['wallet_id'] as String?;
      debugPrint('🏦 Wallet ID: $walletId');
      return walletId;
    } catch (error) {
      debugPrint('❌ Error obteniendo wallet ID: $error');
      return null;
    }
  }

  /// Registrar un movimiento en el historial
  static Future<void> _registrarMovimiento({
    required String userId,
    required String tipo,
    required double cantidad,
    required String concepto,
    String? transactionId,
  }) async {
    try {
      // Obtener el ID de la cuenta
      final cuentaResponse = await _supabase
          .from('cuentas')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (cuentaResponse == null) {
        debugPrint('❌ No se pudo registrar movimiento: cuenta no encontrada');
        return;
      }

      final cuentaId = cuentaResponse['id'];

      // Insertar el movimiento
      await _supabase.from('movimientos').insert({
        'cuenta_id': cuentaId,
        'tipo': tipo,
        'cantidad': cantidad,
        'concepto': concepto,
        'transaction_id': transactionId,
        'fecha': DateTime.now().toIso8601String(),
        'estado': 'completado',
      });

      debugPrint('📝 Movimiento registrado: $tipo - \$${cantidad.toStringAsFixed(2)}');
    } catch (error) {
      debugPrint('❌ Error registrando movimiento: $error');
    }
  }

  /// Obtener historial de movimientos del usuario
  static Future<List<Map<String, dynamic>>> obtenerHistorialMovimientos(String userId, {int limit = 10}) async {
    try {
      // Obtener el ID de la cuenta
      final cuentaResponse = await _supabase
          .from('cuentas')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (cuentaResponse == null) {
        debugPrint('❌ No se encontró cuenta para obtener historial');
        return [];
      }

      final cuentaId = cuentaResponse['id'];

      // Obtener movimientos
      final movimientos = await _supabase
          .from('movimientos')
          .select()
          .eq('cuenta_id', cuentaId)
          .order('fecha', ascending: false)
          .limit(limit);

      debugPrint('📋 Historial obtenido: ${movimientos.length} movimientos');
      return List<Map<String, dynamic>>.from(movimientos);
    } catch (error) {
      debugPrint('❌ Error obteniendo historial: $error');
      return [];
    }
  }

  /// Simular compra exitosa con RevenueCat (para demo)
  static Future<bool> procesarCompraDemo({
    required String userId,
    required String packageId,
    required double cantidad,
  }) async {
    try {
      debugPrint('🛒 Procesando compra demo: $packageId por \$${cantidad.toStringAsFixed(2)}');
      
      // Simular delay de procesamiento
      await Future.delayed(const Duration(seconds: 1));
      
      // Agregar fondos al wallet
      final exito = await agregarFondos(
        userId: userId,
        cantidad: cantidad,
        concepto: 'Recarga $packageId',
        transactionId: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (exito) {
        debugPrint('✅ Compra demo procesada exitosamente');
      } else {
        debugPrint('❌ Error procesando compra demo');
      }

      return exito;
    } catch (error) {
      debugPrint('❌ Error en compra demo: $error');
      return false;
    }
  }
}
