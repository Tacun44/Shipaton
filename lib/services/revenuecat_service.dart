import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

/// Excepción personalizada para indicar que se debe mostrar el paywall simulado
class PaywallSimuladoException implements Exception {
  final String message;
  PaywallSimuladoException(this.message);
  
  @override
  String toString() => message;
}

class RevenueCatService {
  static const String _androidApiKey = 'goog_ihwckQHbfPZYZQYRQwEoBgHlutx';
  static const String _iosApiKey = 'appl_YOUR_IOS_KEY_HERE'; // Reemplazar cuando tengas la key de iOS
  static const String _demoUserId = 'mueve_demo_user';
  
  // Modo de desarrollo para emuladores
  static bool _isDevelopmentMode = false; // Desactivado para testing real en Android
  
  /// Verifica si la plataforma soporta RevenueCat
  static bool isPlatformSupported() {
    return defaultTargetPlatform == TargetPlatform.android || 
           defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Inicializa RevenueCat con la configuración necesaria
  static Future<void> initRC() async {
    try {
      debugPrint('🚀 INICIANDO INICIALIZACIÓN DE REVENUECAT');
      
      // Verificar si la plataforma es compatible
      if (!isPlatformSupported()) {
        debugPrint('⚠️ RevenueCat: Plataforma no soportada (${defaultTargetPlatform.name})');
        debugPrint('💡 RevenueCat solo funciona en iOS y Android');
        return;
      }
      
      debugPrint('📱 Plataforma soportada: ${defaultTargetPlatform.name}');
      
      // Habilitar logs de debug
      debugPrint('🔧 Habilitando logs de debug...');
      await Purchases.setDebugLogsEnabled(true);
      debugPrint('✅ Logs de debug habilitados');
      
      // Configuración según la plataforma
      PurchasesConfiguration configuration;
      if (defaultTargetPlatform == TargetPlatform.android) {
        debugPrint('🤖 Configurando para Android con key: $_androidApiKey');
        configuration = PurchasesConfiguration(_androidApiKey);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint('🍎 Configurando para iOS con key: $_iosApiKey');
        configuration = PurchasesConfiguration(_iosApiKey);
      } else {
        debugPrint('❌ RevenueCat: Plataforma no soportada');
        return;
      }
      
      // Inicializar RevenueCat
      debugPrint('⚙️ Configurando RevenueCat...');
      await Purchases.configure(configuration);
      debugPrint('✅ RevenueCat configurado exitosamente');
      
      // Login con usuario demo
      debugPrint('👤 Logueando usuario demo: $_demoUserId');
      final customerInfo = await Purchases.logIn(_demoUserId);
      debugPrint('✅ Usuario logueado exitosamente');
      debugPrint('📊 Customer Info: ${customerInfo.customerInfo.originalAppUserId}');
      
      // Verificar ofertas disponibles
      debugPrint('🔍 Verificando ofertas disponibles...');
      final offerings = await Purchases.getOfferings();
      debugPrint('📦 Ofertas encontradas: ${offerings.all.length}');
      debugPrint('🎯 Oferta actual: ${offerings.current?.identifier ?? 'ninguna'}');
      
      debugPrint('🎉 REVENUECAT INICIALIZADO COMPLETAMENTE');
      
    } catch (e) {
      debugPrint('❌ ERROR CRÍTICO INICIALIZANDO REVENUECAT: $e');
      debugPrint('🔍 Tipo de error: ${e.runtimeType}');
      debugPrint('📋 Stack trace disponible para más detalles');
    }
  }
  
  /// Muestra el paywall para recargas de fondos
  static Future<void> showTopUpPaywall() async {
    try {
      debugPrint('🚀 INICIANDO showTopUpPaywall()');
      debugPrint('📱 Plataforma: ${defaultTargetPlatform.name}');
      debugPrint('🔧 Modo desarrollo: $_isDevelopmentMode');
      
      // Verificar si la plataforma es compatible
      if (!isPlatformSupported()) {
        debugPrint('⚠️ RevenueCat no disponible en esta plataforma');
        
        // Si está en modo desarrollo, mostrar paywall simulado
        if (_isDevelopmentMode) {
          debugPrint('🔧 Modo desarrollo activado - mostrando paywall simulado');
          return _showDevelopmentPaywall();
        }
        
        throw Exception('Los pagos solo están disponibles en dispositivos móviles (iOS/Android).');
      }
      
      debugPrint('🎯 Abriendo paywall de recargas...');
      debugPrint('🔍 Verificando inicialización de RevenueCat...');
      
      // Verificar que RevenueCat esté inicializado
      try {
        final offerings = await Purchases.getOfferings();
        debugPrint('📦 Ofertas obtenidas: ${offerings.all.length} ofertas disponibles');
        
        if (offerings.current == null) {
          debugPrint('⚠️ No hay ofertas actuales disponibles');
          debugPrint('📋 Ofertas disponibles: ${offerings.all.keys.toList()}');
          debugPrint('🔄 Activando modo simulado por falta de ofertas...');
          return _showDevelopmentPaywall();
        }
        
        debugPrint('✅ Oferta actual encontrada: ${offerings.current!.identifier}');
        debugPrint('💰 Paquetes en oferta actual: ${offerings.current!.availablePackages.length}');
        
        // Abrir paywall principal de RevenueCat
        debugPrint('🎬 Presentando paywall...');
        final result = await RevenueCatUI.presentPaywall();
        
        debugPrint('✅ Paywall resultado: $result');
      } catch (offeringsError) {
        debugPrint('❌ Error obteniendo ofertas: $offeringsError');
        debugPrint('🔄 Activando modo simulado por error...');
        return _showDevelopmentPaywall();
      }
      
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
    debugPrint('🎭 Mostrando paywall simulado visual');
    
    // En lugar de solo logs, esto activará el paywall visual
    // El widget FloatingActionMenu manejará la navegación
    debugPrint('✅ Paywall simulado activado - se mostrará interfaz visual');
    debugPrint('💡 En un dispositivo real con RevenueCat configurado, se abriría el paywall oficial');
    
    // Lanzar excepción especial que indica que debe mostrar paywall simulado
    throw PaywallSimuladoException('Mostrar paywall simulado visual');
  }
  
  /// Verifica si está en modo de desarrollo
  static bool isDevelopmentMode() => _isDevelopmentMode;
  
  /// Fuerza el modo de desarrollo (para testing)
  static void setDevelopmentMode(bool enabled) {
    _isDevelopmentMode = enabled;
    debugPrint('🔧 Modo de desarrollo ${enabled ? 'activado' : 'desactivado'}');
  }
}
