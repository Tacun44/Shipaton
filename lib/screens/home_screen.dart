import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/financial_service.dart';
import '../models/cuenta_model.dart';
import '../widgets/theme_toggle_button.dart';
import '../widgets/floating_action_menu.dart';
import 'qr_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CuentaModel? _cuenta;
  bool _isLoading = true;
  bool _saldoVisible = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosCuenta();
  }

  Future<void> _cargarDatosCuenta() async {
    setState(() => _isLoading = true);

    try {
      final cuenta = await FinancialService.obtenerCuentaPrincipal();
      if (cuenta != null) {
        setState(() {
          _cuenta = cuenta;
          _isLoading = false;
        });
      } else {
        debugPrint('⚠️ No se encontró cuenta, usando datos de Supabase directamente');
        setState(() => _isLoading = false);
      }
    } catch (error) {
      debugPrint('Error al cargar cuenta: $error');
      setState(() => _isLoading = false);
    }
  }

  void _toggleSaldoVisible() {
    setState(() {
      _saldoVisible = !_saldoVisible;
    });
  }

  Future<void> _signOut() async {
    try {
      await AuthService.logout();
      if (mounted) {
        // Navegar de vuelta al login
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
          (route) => false,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesión cerrada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar sesión: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mueve'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        actions: [
          const ThemeToggleButton(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Contenido principal
                Column(
                  children: [
                    // Header con saldo
                    _buildHeaderConSaldo(),
                    
                    // Accesos rápidos
                    Expanded(
                      child: _buildAccesosRapidos(),
                    ),
                  ],
                ),
                
                // Botón flotante
                FloatingActionMenu(
                  onMiCuentaTap: () {
                    // Navegar a mi cuenta
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildHeaderConSaldo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Saludo y nombre
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, ${_cuenta?.nombreUsuario ?? 'Usuario'}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    AuthService.getCurrentUser()?.email ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Avatar
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  (_cuenta?.nombreUsuario ?? 'U').substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Saldo principal
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Saldo disponible',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _saldoVisible 
                        ? '\$${(_cuenta?.saldoPrincipal ?? 0.0).toStringAsFixed(2)}'
                        : '••••••',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _toggleSaldoVisible,
                    child: Icon(
                      _saldoVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Saldo de ahorros
          Row(
            children: [
              Icon(
                Icons.savings,
                color: Colors.white.withOpacity(0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Ahorros: ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                _saldoVisible 
                    ? '\$${(_cuenta?.saldoAhorros ?? 0.0).toStringAsFixed(2)}'
                    : '••••••',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAccesosRapidos() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Accesos rápidos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  context,
                  icon: Icons.send,
                  title: 'Transferir',
                  subtitle: 'Envía dinero',
                  color: const Color(0xFF6B73FF),
                  onTap: () => _mostrarProximamente('Transferencias'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.qr_code_scanner,
                  title: 'QR Pago',
                  subtitle: 'Escanea y paga',
                  color: const Color(0xFF9C88FF),
                  onTap: () => _abrirQR(),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.credit_card,
                  title: 'Pagar',
                  subtitle: 'Servicios',
                  color: const Color(0xFF6B73FF),
                  onTap: () => _mostrarProximamente('Pagos'),
                ),
                _buildQuickActionCard(
                  context,
                  icon: Icons.history,
                  title: 'Historial',
                  subtitle: 'Movimientos',
                  color: const Color(0xFF9C88FF),
                  onTap: () => _mostrarProximamente('Historial'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: Theme.of(context).cardTheme.elevation,
      shape: Theme.of(context).cardTheme.shape,
      color: Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _abrirQR() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QRScreen(cuenta: _cuenta),
      ),
    );
  }

  void _mostrarProximamente(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Próximamente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}