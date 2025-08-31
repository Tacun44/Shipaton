import 'package:flutter/material.dart';
import '../constants/mueve_colors.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  int _selectedPackage = 1; // Paquete seleccionado por defecto
  bool _isLoading = false;

  final List<Map<String, dynamic>> _packages = [
    {
      'id': 'small',
      'title': 'Recarga Básica',
      'amount': '\$10.000',
      'bonus': '+\$1.000 gratis',
      'price': '\$9.99',
      'popular': false,
    },
    {
      'id': 'medium',
      'title': 'Recarga Popular',
      'amount': '\$25.000',
      'bonus': '+\$5.000 gratis',
      'price': '\$19.99',
      'popular': true,
    },
    {
      'id': 'large',
      'title': 'Recarga Premium',
      'amount': '\$50.000',
      'bonus': '+\$15.000 gratis',
      'price': '\$39.99',
      'popular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MueveColors.darkNavy,
      appBar: AppBar(
        backgroundColor: MueveColors.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: MueveColors.pureWhite),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Agregar Fondos',
          style: TextStyle(
            color: MueveColors.pureWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header con logo y descripción
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: MueveColors.brightOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: MueveColors.pureWhite,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Recarga tu cuenta Mueve',
                  style: TextStyle(
                    color: MueveColors.pureWhite,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Elige el paquete que mejor se adapte a tus necesidades',
                  style: TextStyle(
                    color: MueveColors.pureWhite.withOpacity(0.8),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Lista de paquetes
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: MueveColors.pureWhite,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Paquetes
                    Expanded(
                      child: ListView.builder(
                        itemCount: _packages.length,
                        itemBuilder: (context, index) {
                          final package = _packages[index];
                          final isSelected = _selectedPackage == index;
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedPackage = index;
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isSelected 
                                    ? MueveColors.brightOrange.withOpacity(0.1)
                                    : MueveColors.lightGray,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected 
                                      ? MueveColors.brightOrange
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Badge "Popular"
                                  if (package['popular'])
                                    Positioned(
                                      top: -8,
                                      right: -8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: MueveColors.brightOrange,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'POPULAR',
                                          style: TextStyle(
                                            color: MueveColors.pureWhite,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  
                                  Row(
                                    children: [
                                      // Radio button
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected 
                                                ? MueveColors.brightOrange
                                                : MueveColors.secondaryText,
                                            width: 2,
                                          ),
                                          color: isSelected 
                                              ? MueveColors.brightOrange
                                              : Colors.transparent,
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: MueveColors.pureWhite,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      
                                      // Contenido del paquete
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              package['title'],
                                              style: const TextStyle(
                                                color: MueveColors.primaryText,
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              package['amount'],
                                              style: const TextStyle(
                                                color: MueveColors.brightOrange,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              package['bonus'],
                                              style: TextStyle(
                                                color: MueveColors.secondaryText,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      // Precio
                                      Text(
                                        package['price'],
                                        style: const TextStyle(
                                          color: MueveColors.primaryText,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Botón de compra
                    Container(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handlePurchase,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MueveColors.brightOrange,
                          foregroundColor: MueveColors.pureWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: MueveColors.pureWhite,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Comprar ${_packages[_selectedPackage]['price']}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Términos y condiciones
                    Text(
                      'Al continuar, aceptas nuestros términos y condiciones. Esta es una compra simulada para demostración.',
                      style: TextStyle(
                        color: MueveColors.secondaryText,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() {
      _isLoading = true;
    });

    // Simular proceso de compra
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Mostrar éxito
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Compra Simulada Exitosa!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Se han agregado ${_packages[_selectedPackage]['amount']} a tu cuenta (simulado)',
                style: TextStyle(
                  color: MueveColors.secondaryText,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo
                    Navigator.pop(context); // Cerrar paywall
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MueveColors.brightOrange,
                    foregroundColor: MueveColors.pureWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Continuar'),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}
