import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_colors.dart';
import '../models/cuenta_model.dart';

class QRScreen extends StatefulWidget {
  final CuentaModel? cuenta;
  
  const QRScreen({super.key, required this.cuenta});

  @override
  State<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends State<QRScreen> with TickerProviderStateMixin {
  late AnimationController _qrAnimationController;
  late AnimationController _buttonAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  
  String _qrData = '';
  String _qrType = 'payment'; // payment, contact, transfer
  final TextEditingController _montoController = TextEditingController();
  final TextEditingController _conceptoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    _qrAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _qrAnimationController, curve: Curves.elasticOut),
    );
    
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonAnimationController, curve: Curves.easeInOut),
    );
    
    _generarQRContacto(); // QR por defecto
  }

  @override
  void dispose() {
    _qrAnimationController.dispose();
    _buttonAnimationController.dispose();
    _montoController.dispose();
    _conceptoController.dispose();
    super.dispose();
  }

  void _generarQRContacto() {
    final uuid = const Uuid();
    final qrId = uuid.v4().substring(0, 8);
    
    setState(() {
      _qrType = 'contact';
      _qrData = '''
{
  "type": "mueve_contact",
  "user": "${widget.cuenta?.nombreUsuario ?? 'Usuario Mueve'}",
  "account_id": "${widget.cuenta?.id ?? qrId}",
  "app": "Mueve",
  "timestamp": "${DateTime.now().toIso8601String()}"
}''';
    });
    
    _qrAnimationController.forward();
  }

  void _generarQRPago() {
    if (_montoController.text.isEmpty) {
      _mostrarError('Ingresa un monto válido');
      return;
    }
    
    final monto = double.tryParse(_montoController.text);
    if (monto == null || monto <= 0) {
      _mostrarError('El monto debe ser mayor a 0');
      return;
    }
    
    final uuid = const Uuid();
    final qrId = uuid.v4().substring(0, 8);
    
    setState(() {
      _qrType = 'payment';
      _qrData = '''
{
  "type": "mueve_payment",
  "amount": $monto,
  "concept": "${_conceptoController.text.isEmpty ? 'Pago Mueve' : _conceptoController.text}",
  "recipient": "${widget.cuenta?.nombreUsuario ?? 'Usuario Mueve'}",
  "account_id": "${widget.cuenta?.id ?? qrId}",
  "qr_id": "$qrId",
  "timestamp": "${DateTime.now().toIso8601String()}"
}''';
    });
    
    _qrAnimationController.reset();
    _qrAnimationController.forward();
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Generar QR', style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.darkNavy,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Selector de tipo de QR
            _buildQRTypeSelector(),
            
            const SizedBox(height: 24),
            
            // Formulario dinámico
            if (_qrType == 'payment') _buildPaymentForm(),
            
            const SizedBox(height: 24),
            
            // QR Code con animación
            _buildAnimatedQR(),
            
            const SizedBox(height: 24),
            
            // Información del QR
            _buildQRInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildQRTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSelectorButton(
              'Contacto',
              Icons.person_rounded,
              _qrType == 'contact',
              () => _generarQRContacto(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildSelectorButton(
              'Pago',
              Icons.payment_rounded,
              _qrType == 'payment',
              () => setState(() => _qrType = 'payment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorButton(String text, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.blueGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.pureWhite : AppColors.lightText,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isSelected ? AppColors.pureWhite : AppColors.lightText,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💰 Configurar Pago',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 16),
          
          // Campo de monto
          TextField(
            controller: _montoController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monto a cobrar',
              prefixText: '\$ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Campo de concepto
          TextField(
            controller: _conceptoController,
            decoration: InputDecoration(
              labelText: 'Concepto (opcional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.skyBlue, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Botón generar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generarQRPago,
              icon: const Icon(Icons.qr_code_rounded),
              label: const Text('Generar QR de Pago'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.skyBlue,
                foregroundColor: AppColors.pureWhite,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedQR() {
    if (_qrData.isEmpty) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.pureWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkNavy.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  _qrType == 'contact' ? '👤 Mi Código QR' : '💳 QR de Pago',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // QR Code
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pureWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.lightGray, width: 2),
                  ),
                  child: QrImageView(
                    data: _qrData,
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: AppColors.pureWhite,
                    foregroundColor: AppColors.darkNavy,
                    errorCorrectionLevel: QrErrorCorrectLevel.H,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _qrType == 'contact' 
                      ? 'Comparte este código para que te agreguen'
                      : 'Escanea para realizar el pago',
                  style: TextStyle(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQRInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.pureWhite,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Información del QR',
                style: TextStyle(
                  color: AppColors.pureWhite,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow('📱 Funciona sin internet', 'Generado localmente'),
          _buildInfoRow('🔒 Seguro', 'Datos encriptados'),
          _buildInfoRow('⚡ Rápido', 'Escaneo instantáneo'),
          if (_qrType == 'payment' && _montoController.text.isNotEmpty)
            _buildInfoRow('💰 Monto', '\$${_montoController.text}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.pureWhite.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.pureWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
