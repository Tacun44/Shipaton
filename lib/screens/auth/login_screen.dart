import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../constants/app_colors.dart';
import 'register_screen.dart';
import 'biometric_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  
  // Variables para biometría
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricTypeName = 'Biometría';

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initBiometric() async {
    try {
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isEnabled = await BiometricService.isBiometricEnabled();
      final savedEmail = await BiometricService.getSavedEmail();
      final typeName = await BiometricService.getBiometricTypeName();

      setState(() {
        _isBiometricAvailable = isAvailable;
        _isBiometricEnabled = isEnabled;
        _biometricTypeName = typeName;
      });

      // Si hay email guardado, pre-llenarlo
      if (savedEmail != null) {
        _emailController.text = savedEmail;
      }
    } catch (e) {
      debugPrint('Error inicializando biometría: $e');
    }
  }

  Future<void> _signInWithBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BiometricService.signInWithBiometric();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡Bienvenido de vuelta con $_biometricTypeName!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error biométrico: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      
      await AuthService.signIn(email: email, password: password);
      
      if (mounted) {
        // Mostrar mensaje de bienvenida
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Bienvenido!'),
            backgroundColor: Colors.green,
          ),
        );

        // Verificar si debe mostrar configuración biométrica
        await _checkAndShowBiometricSetup(email, password);
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAndShowBiometricSetup(String email, String password) async {
    try {
      // Solo mostrar si la biometría está disponible pero no configurada
      final isAvailable = await BiometricService.isBiometricAvailable();
      final isEnabled = await BiometricService.isBiometricEnabled();
      
      if (isAvailable && !isEnabled && mounted) {
        // Esperar un poco para que se complete la navegación del AuthWrapper
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => BiometricSetupScreen(
                email: email,
                password: password,
              ),
            ),
          );
          
          if (result == true) {
            // Biometría configurada, actualizar estado
            await _initBiometric();
          }
        }
      }
    } catch (e) {
      debugPrint('Error verificando configuración biométrica: $e');
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa tu email'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await AuthService.resetPassword(_emailController.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Se ha enviado un email para restablecer tu contraseña'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo animado de Mueve
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentOrange.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: AppColors.pureWhite,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Mueve',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu dinero en movimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.secondaryText,
                  ),
                ),
                
                const SizedBox(height: 48),
                
                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_rounded, color: AppColors.skyBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Por favor ingresa un email válido';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Campo de contraseña
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock_rounded, color: AppColors.skyBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: AppColors.lightText,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 8),
                
                // Enlace para restablecer contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetPassword,
                    child: Text(
                      '¿Olvidaste tu contraseña?',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botón de iniciar sesión
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.skyBlue,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.pureWhite,
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
                
                // Botón de autenticación biométrica (si está disponible)
                if (_isBiometricAvailable && _isBiometricEnabled) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signInWithBiometric,
                      icon: Icon(_getBiometricIcon()),
                      label: Text('Usar $_biometricTypeName'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[300])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'o',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[300])),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Enlace para registrarse
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Regístrate',
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getBiometricIcon() {
    if (_biometricTypeName.contains('Face')) {
      return Icons.face;
    } else if (_biometricTypeName.contains('Huella')) {
      return Icons.fingerprint;
    } else {
      return Icons.security;
    }
  }
}
