import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const String _androidApiKey = 'goog_ihwckQHbfPZYZQYRQwEoBgHlutx';
  static const String _iosApiKey = 'appl_YOUR_IOS_KEY_HERE'; // Reemplazar cuando tengas la key de iOS
  static const String _demoUserId = 'mueve_demo_user';
  
  // Modo de desarrollo para emuladores
  static bool _isDevelopmentMode = false;
  
  /// Verifica si la plataforma soporta RevenueCat
  static bool isPlatformSupported() {
    return defaultTargetPlatform == TargetPlatform.android || 
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Inicializa RevenueCat con la configuración necesaria
  static Future<void> initRC() async {
    try {
      // Verificar si la plataforma es compatible
      if (!isPlatformSupported()) {
        debugPrint('⚠️ RevenueCat: Plataforma no soportada (${defaultTargetPlatform.name})');
        debugPrint('💡 RevenueCat solo funciona en iOS y Android');
        return;
      }
      
      // Habilitar logs de debug
      await Purchases.setDebugLogsEnabled(true);
      
      // Configuración según la plataforma
      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        configuration = PurchasesConfiguration(_androidApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        configuration = PurchasesConfiguration(_iosApiKey);
      } else {
        debugPrint('RevenueCat: Plataforma no soportada');
        return;
      }
      
      // Inicializar RevenueCat
      await Purchases.configure(configuration);
      
      // Login con usuario demo
      await Purchases.logIn(_demoUserId);
      
      debugPrint('✅ RevenueCat inicializado correctamente');
      debugPrint('👤 Usuario logueado: $_demoUserId');
      
    } catch (e) {
      debugPrint('❌ Error inicializando RevenueCat: $e');
    }
  }
  
  /// Muestra el paywall para recargas de fondos
  static Future<void> showTopUpPaywall() async {
    try {
      // Verificar si la plataforma es compatible
      if (!isPlatformSupported()) {
        debugPrint('⚠️ RevenueCat no disponible en esta plataforma');
        throw Exception('Los pagos solo están disponibles en dispositivos móviles (iOS/Android).');
      }
      
      debugPrint('🎯 Abriendo paywall de recargas...');
      
      // Verificar que RevenueCat esté inicializado
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) {
        debugPrint('⚠️ No hay ofertas disponibles');
        throw Exception('No hay ofertas disponibles en este momento.');
      }
      
      // Abrir paywall principal de RevenueCat
      final result = await RevenueCatUI.presentPaywall();
      
      debugPrint('✅ Paywall resultado: $result');
      
      // Opción alternativa: Abrir por offering específico (comentado)
      /*
      await RevenueCatUI.presentPaywall(
        offering: offerings.current!,
      );
      */
      
      // Opción con paywall identifier específico (comentado)
      /*
      await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlementIdentifier: 'funds_packs',
      );
      */
      
    } catch (e) {
      debugPrint('❌ Error mostrando paywall: $e');
      
      // Verificar si es un error de emulador/dispositivo sin Google Play Services
      if (e.toString().contains('BILLING_UNAVAILABLE') || 
          e.toString().contains('Billing is not available') ||
          e.toString().contains('PurchaseNotAllowedError')) {
        debugPrint('🔧 Detectado: Emulador sin Google Play Services o dispositivo no compatible');
        
        // Activar modo de desarrollo automáticamente
        _isDevelopmentMode = true;
        debugPrint('🚀 Activando modo de desarrollo para emuladores');
        
        // Mostrar paywall simulado
        return _showDevelopmentPaywall();
      }
      
      // Fallback: mostrar mensaje al usuario
      throw Exception('No se pudo abrir la pasarela de pago. Verifica tu conexión e inténtalo más tarde.');
    }
  }
  
  /// Obtiene información del usuario actual
  static Future<CustomerInfo?> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      debugPrint('📊 Info del cliente obtenida');
      return customerInfo;
    } catch (e) {
      debugPrint('❌ Error obteniendo info del cliente: $e');
      return null;
    }
  }
  
  /// Verifica si el usuario tiene alguna suscripción activa
  static Future<bool> hasActiveSubscription() async {
    try {
      final customerInfo = await getCustomerInfo();
      return customerInfo?.entitlements.active.isNotEmpty ?? false;
    } catch (e) {
      debugPrint('❌ Error verificando suscripciones: $e');
      return false;
    }
  }
  
  /// Obtiene las ofertas disponibles
  static Future<Offerings?> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      debugPrint('💰 Ofertas obtenidas: ${offerings.all.length} disponibles');
      return offerings;
    } catch (e) {
      debugPrint('❌ Error obteniendo ofertas: $e');
      return null;
    }
  }
  
  /// Muestra un paywall simulado para desarrollo en emuladores
  static Future<void> _showDevelopmentPaywall() async {
    debugPrint('🎭 Mostrando paywall simulado para desarrollo');
    
    // Simular un pequeño delay como si fuera una compra real
    await Future.delayed(const Duration(seconds: 1));
    
    debugPrint('✅ Paywall de desarrollo completado');
    debugPrint('💡 En un dispositivo real, aquí se abriría el paywall de RevenueCat');
    
    // En lugar de lanzar una excepción, simplemente completamos exitosamente
    // La UI puede manejar esto como una compra simulada exitosa
  }
  
  /// Verifica si está en modo de desarrollo
  static bool isDevelopmentMode() => _isDevelopmentMode;
  
  /// Fuerza el modo de desarrollo (para testing)
  static void setDevelopmentMode(bool enabled) {
    _isDevelopmentMode = enabled;
    debugPrint('🔧 Modo de desarrollo ${enabled ? 'activado' : 'desactivado'}');
  }
}
