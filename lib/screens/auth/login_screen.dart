import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../constants/mueve_colors.dart';
import 'register_screen.dart';
import 'biometric_setup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Variables para biometría
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  String _biometricTypeName = 'Biometría';
  
  // Controladores de animación
  late AnimationController _logoAnimationController;
  late AnimationController _formAnimationController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoOpacityAnimation;
  late Animation<Offset> _formSlideAnimation;

  @override
  void initState() {
    super.initState();
    _initBiometric();
    _initAnimations();
  }
  
  void _initAnimations() {
    // Animación del logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _logoOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    // Animación del formulario
    _formAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _formSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _formAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Iniciar animaciones
    _logoAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _formAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _logoAnimationController.dispose();
    _formAnimationController.dispose();
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

      debugPrint('🔐 Iniciando login desde LoginScreen: $email');

      // Usar el método login que retorna AuthResult
      final result = await AuthService.login(email, password);

      if (mounted) {
        if (result.success) {
          // Login exitoso - navegar directamente al HomeScreen
          debugPrint('✅ Login exitoso - navegando a HomeScreen');

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.success,
            ),
          );

          // Navegar directamente al HomeScreen
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomeScreen(),
            ),
          );
        } else {
          // Login fallido
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error de conexión: $e'),
            backgroundColor: AppColors.error,
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

  Future<void> _checkAndShowBiometricSetup(
      String email, String password) async {
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
            content:
                Text('Se ha enviado un email para restablecer tu contraseña'),
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
      backgroundColor: MueveColors.lightGray,
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
                AnimatedBuilder(
                  animation: _logoAnimationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Opacity(
                        opacity: _logoOpacityAnimation.value,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: MueveColors.skyBlue.withOpacity(0.3),
                                blurRadius: 25,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.asset(
                              'assets/mueve_logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Text(
                  'Mueve',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: MueveColors.primaryText,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tu dinero en movimiento',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: MueveColors.secondaryText,
                    fontWeight: FontWeight.w400,
                  ),
                ),

                const SizedBox(height: 48),
                // Campo de email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon:
                        Icon(Icons.email_rounded, color: AppColors.skyBlue),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: AppColors.skyBlue, width: 2),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor ingresa tu email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
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
                    prefixIcon:
                        Icon(Icons.lock_rounded, color: AppColors.skyBlue),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
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
                      borderSide:
                          const BorderSide(color: AppColors.skyBlue, width: 2),
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
                      backgroundColor: MueveColors.skyBlue,
                      foregroundColor: MueveColors.pureWhite,
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
                              color: MueveColors.pureWhite,
                            ),
                          )
                        : const Text(
                            'Iniciar Sesión',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
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
                                color: MueveColors.skyBlue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
