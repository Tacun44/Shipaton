import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'services/database_service.dart';
import 'services/revenuecat_service.dart';
import 'widgets/auth_wrapper.dart';
import 'constants/mueve_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Supabase
  await SupabaseConfig.initialize();
  
  // Inicializar RevenueCat
  await RevenueCatService.initRC();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mueve - Tu dinero en movimiento',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: MueveColors.darkNavy),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
        brightness: Brightness.light,
        scaffoldBackgroundColor: MueveColors.lightGray,
        primaryColor: MueveColors.darkNavy,
        appBarTheme: const AppBarTheme(
          backgroundColor: MueveColors.darkNavy,
          foregroundColor: MueveColors.pureWhite,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: MueveColors.skyBlue,
            foregroundColor: MueveColors.pureWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MueveColors.mediumGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: MueveColors.skyBlue, width: 2),
          ),
          labelStyle: TextStyle(color: MueveColors.secondaryText),
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}


