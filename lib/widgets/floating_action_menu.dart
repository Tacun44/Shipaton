import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FloatingActionMenu extends StatefulWidget {
  final VoidCallback onMiCuentaTap;
  
  const FloatingActionMenu({
    super.key,
    required this.onMiCuentaTap,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _rotationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _blurAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    
    // Controlador principal para el menú
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Controlador para la rotación del botón
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Animación principal (opacidad y posición)
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOutBack,
      ),
    );
    
    // Animación de escala estilo iPhone
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.elasticOut,
      ),
    );
    
    // Animación de deslizamiento
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Rotación del icono +
    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _rotationController, 
        curve: Curves.easeInOut,
      ),
    );
    
    // Animación de blur para el fondo
    _blurAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(
        parent: _animationController, 
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    
    if (_isOpen) {
      _animationController.forward();
      _rotationController.forward();
    } else {
      _animationController.reverse();
      _rotationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Overlay con blur estilo iOS
        if (_isOpen)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleMenu,
              child: AnimatedBuilder(
                animation: _blurAnimation,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkNavy.withOpacity(0.4 * _animation.value),
                    ),
                  );
                },
              ),
            ),
          ),
        
        // Botones del menú con animación estilo iPhone
        Positioned(
          bottom: 100,
          right: 24,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildMenuOptionIPhone(
                    Icons.person_outline,
                    'Mi Cuenta',
                    AppColors.skyBlue,
                    widget.onMiCuentaTap,
                    0,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuOptionIPhone(
                    Icons.bar_chart_rounded,
                    'Estadísticas',
                    AppColors.purple,
                    () => _showComingSoon('Estadísticas'),
                    1,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuOptionIPhone(
                    Icons.help_outline_rounded,
                    'Ayuda',
                    AppColors.success,
                    () => _showComingSoon('Ayuda'),
                    2,
                  ),
                  const SizedBox(height: 16),
                  _buildMenuOptionIPhone(
                    Icons.settings_outlined,
                    'Configuración',
                    AppColors.secondaryText,
                    () => _showComingSoon('Configuración'),
                    3,
                  ),
                ],
              );
            },
          ),
        ),
        
        // Botón principal flotante estilo iPhone
        Positioned(
          bottom: 24,
          right: 24,
          child: AnimatedBuilder(
            animation: _rotationController,
            builder: (context, child) {
              return Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleMenu,
                    borderRadius: BorderRadius.circular(32),
                    child: Center(
                      child: AnimatedRotation(
                        duration: const Duration(milliseconds: 300),
                        turns: _rotationAnimation.value,
                        child: Icon(
                          _isOpen ? Icons.close_rounded : Icons.add_rounded,
                          color: AppColors.pureWhite,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMenuOptionIPhone(IconData icon, String label, Color color, VoidCallback onTap, int index) {
    final delay = index * 0.1;
    final animationValue = Curves.easeOutBack.transform(
      (_animation.value - delay).clamp(0.0, 1.0) / (1.0 - delay),
    );
    
    return Transform.translate(
      offset: Offset(_slideAnimation.value * animationValue, 0),
      child: Transform.scale(
        scale: _scaleAnimation.value * animationValue,
        child: Opacity(
          opacity: _animation.value,
          child: Container(
            margin: EdgeInsets.only(right: 8 * (1 - animationValue)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Label del botón
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                
                // Botón circular
                GestureDetector(
                  onTap: () {
                    _toggleMenu();
                    onTap();
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.pureWhite,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        backgroundColor: AppColors.darkNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
