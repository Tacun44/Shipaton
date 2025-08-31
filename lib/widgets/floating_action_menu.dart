import 'package:flutter/material.dart';
import '../constants/mueve_colors.dart';
import '../services/revenuecat_service.dart';
import '../screens/paywall_screen.dart';

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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _openRevenueCatPaywall() async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    // Animación de presión
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    
    try {
      await RevenueCatService.showTopUpPaywall();
      
      // Si llegamos aquí, RevenueCat funcionó correctamente
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✅ Paywall de RevenueCat completado',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Verificar si es la excepción especial para paywall simulado
        if (e is PaywallSimuladoException) {
          // Mostrar paywall simulado visual
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PaywallScreen(),
              fullscreenDialog: true,
            ),
          );
        } else {
          // Error real de RevenueCat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: MueveColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_animationController.value * 0.1),
            child: GestureDetector(
              onTap: _openRevenueCatPaywall,
              child: Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  gradient: MueveColors.accentGradient,
                  borderRadius: BorderRadius.circular(34),
                  boxShadow: [
                    BoxShadow(
                      color: MueveColors.brightOrange.withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: _isLoading
                    ? Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              MueveColors.pureWhite,
                            ),
                          ),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_card_rounded,
                            color: MueveColors.pureWhite,
                            size: 26,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'FONDOS',
                            style: TextStyle(
                              color: MueveColors.pureWhite,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}