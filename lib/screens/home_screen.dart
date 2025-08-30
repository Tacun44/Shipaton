import 'package:flutter/material.dart';
import '../models/cuenta_model.dart';
import '../services/financial_service.dart';
import '../widgets/floating_action_menu.dart';
import 'account_screen.dart';
import 'qr_screen.dart';
import '../constants/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CuentaModel? _cuenta;
  bool _cargando = true;
  bool _saldoVisible = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosCuenta();
  }

  Future<void> _cargarDatosCuenta() async {
    setState(() => _cargando = true);
    
    try {
      final cuenta = await FinancialService.obtenerCuentaPrincipal();
      setState(() {
        _cuenta = cuenta;
        _cargando = false;
      });
    } catch (error) {
      print('Error al cargar cuenta: $error');
      setState(() => _cargando = false);
    }
  }

  void _toggleSaldoVisible() {
    setState(() {
      _saldoVisible = !_saldoVisible;
    });
  }

  Future<void> _recargarFondos() async {
    // Mostrar diálogo para ingresar monto
    final TextEditingController montoController = TextEditingController();
    
    final resultado = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('💰 Recargar Fondos'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Ingresa el monto a recargar:'),
              const SizedBox(height: 16),
              TextField(
                controller: montoController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Recargar'),
            ),
          ],
        );
      },
    );

    if (resultado == true && montoController.text.isNotEmpty) {
      final monto = double.tryParse(montoController.text);
      if (monto != null && monto > 0) {
        await _procesarRecarga(monto);
      }
    }
  }

  Future<void> _procesarRecarga(double monto) async {
    setState(() => _cargando = true);
    
    try {
      // Agregar movimiento de recarga
      final exito = await FinancialService.agregarMovimiento(
        descripcion: 'Recarga de fondos',
        monto: monto,
        tipo: TipoMovimiento.ingreso,
        categoria: 'Recarga',
      );

      if (exito) {
        await _cargarDatosCuenta();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Recarga exitosa: +\$${monto.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al procesar la recarga'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
    
    setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      backgroundColor: AppColors.lightGray, // Fondo gris claro para diferenciar
      body: SafeArea(
        child: Stack(
          children: [
            // Contenido principal
            _cargando
                ? const Center(child: CircularProgressIndicator(color: AppColors.darkNavy))
                : Column(
                    children: [
                                        // Header con saldo (fondo diferenciado)
                  _buildHeaderConSaldo(),
                  
                  // Accesos rápidos dinámicos
                  _buildAccesosRapidos(),

                  // Últimos movimientos (historial con scroll)
                  Expanded(
                    child: _buildUltimosMovimientos(),
                  ),
                    ],
                  ),
            
            // Menú flotante integrado
            FloatingActionMenu(
              onMiCuentaTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AccountScreen(cuenta: _cuenta),
                  ),
                );
              },
              onQRTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScreen(cuenta: _cuenta),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccesosRapidos() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildAccesoRapido(
              'Transferir',
              Icons.send_rounded,
              AppColors.skyBlue,
              () => _mostrarProximamente('Transferencias'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAccesoRapido(
              'QR Pago',
              Icons.qr_code_rounded,
              AppColors.purple,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QRScreen(cuenta: _cuenta),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildAccesoRapido(
              'Pagar',
              Icons.payment_rounded,
              AppColors.accentOrange,
              () => _mostrarProximamente('Pagos'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccesoRapido(String titulo, IconData icono, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.pureWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icono,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              titulo,
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarProximamente(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        backgroundColor: AppColors.darkNavy,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

    Widget _buildHeaderConSaldo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20.0), // Reducido de 24 a 20
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo y nombre de la app
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mueve',
                    style: TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 24, // Reducido de 28 a 24
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hola, ${_cuenta?.nombreUsuario.split(' ').first ?? 'Usuario'}',
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 14, // Reducido de 16 a 14
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20), // Reducido de 32 a 20
          
          // Saldo principal con ojito y botón de recarga
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo disponible',
                      style: TextStyle(
                        color: AppColors.pureWhite.withOpacity(0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          _saldoVisible 
                              ? '\$${(_cuenta?.saldoPrincipal ?? 0).toStringAsFixed(2)}'
                              : '••••••••',
                          style: const TextStyle(
                            color: AppColors.pureWhite,
                            fontSize: 28, // Reducido de 36 a 28
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: _toggleSaldoVisible,
                          icon: Icon(
                            _saldoVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                            color: AppColors.pureWhite.withOpacity(0.7),
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                    if (_cuenta?.saldoAhorros != null && (_cuenta!.saldoAhorros > 0))
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Ahorros: ${_saldoVisible ? '\$${_cuenta!.saldoAhorros.toStringAsFixed(2)}' : '••••••'}',
                          style: TextStyle(
                            color: AppColors.pureWhite.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Botón de recarga
              Container(
                width: 44, // Tamaño fijo más pequeño
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12), // Menos redondeado
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withOpacity(0.3),
                      blurRadius: 8, // Reducido
                      offset: const Offset(0, 3), // Reducido
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _recargarFondos,
                  padding: EdgeInsets.zero, // Sin padding extra
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.pureWhite,
                    size: 20, // Reducido de 28 a 20
                  ),
                  tooltip: 'Recargar fondos',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }











  Widget _buildUltimosMovimientos() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 80), // Sin margen superior
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24), // Más redondeado
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkNavy.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del historial
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12), // Reducido
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historial de movimientos',
                  style: TextStyle(
                    fontSize: 18, // Reducido de 20 a 18
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Icon(
                  Icons.history_rounded,
                  color: AppColors.lightText,
                  size: 20, // Reducido
                ),
              ],
            ),
          ),
          
                                // Lista scrolleable de movimientos
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16), // Reducido de 24 a 16
                          children: [
                _buildMovimientoItemAnimado('Salario mensual', 12000.00, Icons.work_rounded, AppColors.success, 'Hace 2 días'),
                _buildMovimientoItemAnimado('Compra supermercado', -450.30, Icons.shopping_cart_rounded, AppColors.error, 'Hace 1 día'),
                _buildMovimientoItemAnimado('Pago Netflix', -49.90, Icons.movie_rounded, AppColors.error, 'Hace 1 día'),
                _buildMovimientoItemAnimado('Transferencia recibida', 500.00, Icons.send_rounded, AppColors.success, 'Hoy'),
                _buildMovimientoItemAnimado('Pago luz', -180.75, Icons.electrical_services_rounded, AppColors.error, 'Hoy'),
                _buildMovimientoItemAnimado('Recarga de fondos', 1000.00, Icons.add_circle_rounded, AppColors.skyBlue, 'Hoy'),
                _buildMovimientoItemAnimado('Compra gasolina', -250.00, Icons.local_gas_station_rounded, AppColors.error, 'Ayer'),
                _buildMovimientoItemAnimado('Pago internet', -89.90, Icons.wifi_rounded, AppColors.error, 'Hace 3 días'),
                _buildMovimientoItemAnimado('Transferencia enviada', -300.00, Icons.send_rounded, AppColors.warning, 'Hace 3 días'),
                _buildMovimientoItemAnimado('Depósito bancario', 2500.00, Icons.account_balance_rounded, AppColors.success, 'Hace 1 semana'),
              ],
            ),
          ),
          
          const SizedBox(height: 12), // Reducido de 20 a 12
        ],
      ),
    );
  }

  Widget _buildMovimientoItemAnimado(String descripcion, double monto, IconData icon, Color color, String fecha) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3), // Reducido de 4 a 3
      padding: const EdgeInsets.all(12), // Reducido de 16 a 12
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(10), // Reducido de 12 a 10
        border: Border.all(color: Colors.transparent),
      ),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Detalles de: $descripcion'),
              backgroundColor: AppColors.darkNavy,
            ),
          );
        },
        borderRadius: BorderRadius.circular(10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8), // Reducido de 12 a 8
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8), // Reducido
              ),
              child: Icon(icon, color: color, size: 20), // Reducido de 24 a 20
            ),
            const SizedBox(width: 12), // Reducido de 16 a 12
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    descripcion,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14, // Reducido de 15 a 14
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 2), // Reducido de 4 a 2
                  Text(
                    fecha,
                    style: TextStyle(
                      color: AppColors.lightText,
                      fontSize: 12, // Reducido de 13 a 12
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // Reducido
              decoration: BoxDecoration(
                color: monto >= 0 ? AppColors.success.withOpacity(0.1) : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16), // Reducido de 20 a 16
              ),
              child: Text(
                '${monto >= 0 ? '+' : ''}\$${monto.toStringAsFixed(2)}',
                style: TextStyle(
                  color: monto >= 0 ? AppColors.success : AppColors.error,
                  fontWeight: FontWeight.bold,
                  fontSize: 13, // Reducido de 15 a 13
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
