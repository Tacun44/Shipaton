import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const String _androidApiKey = 'goog_ihwckQHbfPZYZQYRQwEoBgHlutx';
  static const String _iosApiKey = 'appl_YOUR_IOS_KEY_HERE'; // Reemplazar cuando tengas la key de iOS
  static const String _demoUserId = 'mueve_demo_user';
  
  /// Inicializa RevenueCat con la configuración necesaria
  static Future<void> initRC() async {
    try {
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
      debugPrint('🎯 Abriendo paywall de recargas...');
      
      // Opción 1: Abrir paywall general
      await RevenueCatUI.presentPaywall();
      
      // Opción 2: Abrir por paywall identifier (comentado para usar cuando tengas el ID)
      /*
      await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlementIdentifier: 'premium',
      );
      */
      
      // Opción 3: Usar paywall específico (descomenta cuando tengas configurado)
      /*
      await RevenueCatUI.presentPaywall(
        displayCloseButton: true,
      );
      */
      
    } catch (e) {
      debugPrint('❌ Error mostrando paywall: $e');
      
      // Fallback: mostrar mensaje al usuario
      throw Exception('No se pudo abrir la pasarela de pago. Inténtalo más tarde.');
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
}
