import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/database_service.dart';
import 'widgets/auth_wrapper.dart';
import 'constants/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con manejo de errores
  try {
    await SupabaseConfig.initialize();
    print('🚀 Supabase inicializado - App iniciando');
  } catch (error) {
    print('⚠️ Error al inicializar Supabase: $error');
    print('📱 Continuando con modo offline...');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mueve - Tu dinero en movimiento',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.darkNavy),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightGray,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkNavy,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
