import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class FloatingActionMenu extends StatefulWidget {
  final VoidCallback onMiCuentaTap;
  final VoidCallback? onQRTap;
  
  const FloatingActionMenu({
    super.key,
    required this.onMiCuentaTap,
    this.onQRTap,
  });

  @override
  State<FloatingActionMenu> createState() => _FloatingActionMenuState();
}

class _FloatingActionMenuState extends State<FloatingActionMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
    });
    
    if (_isOpen) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Botones del menú
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (_isOpen) ...[
                    _buildSimpleMenuOption(
                      Icons.qr_code_rounded,
                      'Generar QR',
                      AppColors.purple,
                      widget.onQRTap ?? () => _showComingSoon('QR'),
                    ),
                    const SizedBox(height: 12),
                    _buildSimpleMenuOption(
                      Icons.person_outline,
                      'Mi Cuenta',
                      AppColors.skyBlue,
                      widget.onMiCuentaTap,
                    ),
                    const SizedBox(height: 12),
                    _buildSimpleMenuOption(
                      Icons.bar_chart_rounded,
                      'Estadísticas',
                      AppColors.accentOrange,
                      () => _showComingSoon('Estadísticas'),
                    ),
                    const SizedBox(height: 12),
                    _buildSimpleMenuOption(
                      Icons.settings_outlined,
                      'Configuración',
                      AppColors.secondaryText,
                      () => _showComingSoon('Configuración'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ],
              );
            },
          ),
          
          // Botón principal
          GestureDetector(
            onTap: _toggleMenu,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentOrange.withOpacity(0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedRotation(
                duration: const Duration(milliseconds: 200),
                turns: _isOpen ? 0.125 : 0.0, // 45 grados
                child: Icon(
                  _isOpen ? Icons.close_rounded : Icons.add_rounded,
                  color: AppColors.pureWhite,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMenuOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: _animationController.value,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: _animationController.value,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Label
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Botón
            GestureDetector(
              onTap: () {
                _toggleMenu();
                onTap();
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.pureWhite,
                  size: 20,
                ),
              ),
            ),
          ],
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