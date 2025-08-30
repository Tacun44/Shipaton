import 'package:flutter/material.dart';
import '../../services/biometric_service.dart';

class BiometricSetupScreen extends StatefulWidget {
  final String email;
  final String password;
  
  const BiometricSetupScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<BiometricSetupScreen> createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  bool _isLoading = false;
  String _biometricTypeName = 'Biometría';

  @override
  void initState() {
    super.initState();
    _loadBiometricInfo();
  }

  Future<void> _loadBiometricInfo() async {
    try {
      final typeName = await BiometricService.getBiometricTypeName();
      setState(() {
        _biometricTypeName = typeName;
      });
    } catch (e) {
      debugPrint('Error cargando info biométrica: $e');
    }
  }

  Future<void> _setupBiometric() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final success = await BiometricService.setupBiometricAuth(
        email: widget.email,
        password: widget.password,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('¡$_biometricTypeName configurado exitosamente!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Indicar que se configuró
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
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _skipSetup() {
    Navigator.of(context).pop(false); // Indicar que se omitió
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícono principal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getBiometricIcon(),
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Título
              Text(
                '¡Acceso Rápido!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              // Descripción
              Text(
                'Configura $_biometricTypeName para iniciar sesión de forma rápida y segura sin necesidad de escribir tu contraseña cada vez.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Beneficios
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildBenefitItem(
                        icon: Icons.speed,
                        title: 'Acceso Instantáneo',
                        subtitle: 'Inicia sesión en segundos',
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        icon: Icons.security,
                        title: 'Máxima Seguridad',
                        subtitle: 'Tu biometría es única e intransferible',
                      ),
                      const SizedBox(height: 16),
                      _buildBenefitItem(
                        icon: Icons.smartphone,
                        title: 'Conveniencia',
                        subtitle: 'No más contraseñas que recordar',
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botón de configurar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _setupBiometric,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(_getBiometricIcon()),
                  label: Text(
                    _isLoading ? 'Configurando...' : 'Configurar $_biometricTypeName',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Botón de omitir
              TextButton(
                onPressed: _isLoading ? null : _skipSetup,
                child: Text(
                  'Omitir por ahora',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
