import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/database_service.dart';
import 'services/revenuecat_service.dart';
import 'services/auth_service.dart';
import 'services/theme_service.dart';
import 'widgets/auth_wrapper.dart';
import 'constants/mueve_colors.dart';
import 'constants/app_themes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar RevenueCat
  await RevenueCatService.initRC();
  
  // Inicializar tema
  await ThemeService().initTheme();
  
  // TEMPORAL: Limpiar estado de autenticación en desarrollo
  // Descomenta la siguiente línea si necesitas resetear el login
  // await AuthService.clearAuthState();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, child) {
        return MaterialApp(
          title: 'Mueve - Tu dinero en movimiento',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: ThemeService().themeMode,
          home: const AuthWrapper(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
