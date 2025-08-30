import 'package:flutter/material.dart';
import '../models/cuenta_model.dart';
import '../services/financial_service.dart';
import '../widgets/floating_action_menu.dart';
import 'account_screen.dart';
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
        child: _cargando
            ? const Center(child: CircularProgressIndicator(color: AppColors.darkNavy))
            : Column(
                children: [
                  // Header con saldo (fondo diferenciado)
                  _buildHeaderConSaldo(),
                  
                  // Últimos movimientos (historial con scroll)
                  Expanded(
                    child: _buildUltimosMovimientos(),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionMenu(
        onMiCuentaTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountScreen(cuenta: _cuenta),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderConSaldo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Hola, ${_cuenta?.nombreUsuario.split(' ').first ?? 'Usuario'}',
                    style: const TextStyle(
                      color: AppColors.pureWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
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
                            fontSize: 36,
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
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _recargarFondos,
                  icon: const Icon(
                    Icons.add_rounded,
                    color: AppColors.pureWhite,
                    size: 28,
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
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Historial de movimientos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                Icon(
                  Icons.history,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          // Lista scrolleable de movimientos
          SizedBox(
            height: 400, // Altura fija para el scroll
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildMovimientoItemAnimated('Salario mensual', 12000.00, Icons.work, Colors.green, 'Hace 2 días'),
                _buildMovimientoItemAnimated('Compra supermercado', -450.30, Icons.shopping_cart, Colors.red, 'Hace 1 día'),
                _buildMovimientoItemAnimated('Pago Netflix', -49.90, Icons.movie, Colors.red, 'Hace 1 día'),
                _buildMovimientoItemAnimated('Transferencia recibida', 500.00, Icons.send, Colors.green, 'Hoy'),
                _buildMovimientoItemAnimated('Pago luz', -180.75, Icons.electrical_services, Colors.red, 'Hoy'),
                _buildMovimientoItemAnimated('Recarga de fondos', 1000.00, Icons.add_circle, Colors.blue, 'Hoy'),
                _buildMovimientoItemAnimated('Compra gasolina', -250.00, Icons.local_gas_station, Colors.red, 'Ayer'),
                _buildMovimientoItemAnimated('Pago internet', -89.90, Icons.wifi, Colors.red, 'Hace 3 días'),
                _buildMovimientoItemAnimated('Transferencia enviada', -300.00, Icons.send, Colors.orange, 'Hace 3 días'),
                _buildMovimientoItemAnimated('Depósito bancario', 2500.00, Icons.account_balance, Colors.green, 'Hace 1 semana'),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMovimientoItemAnimated(String descripcion, double monto, IconData icon, Color color, String fecha) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.transparent),
        ),
        child: InkWell(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Detalles de: $descripcion'),
                backgroundColor: const Color(0xFF2C3E50),
              ),
            );
          },
          onHover: (isHovering) {
            // La animación se maneja automáticamente por InkWell
          },
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fecha,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: monto >= 0 ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${monto >= 0 ? '+' : ''}\$${monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: monto >= 0 ? Colors.green[700] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
