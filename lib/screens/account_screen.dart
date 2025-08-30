import 'package:flutter/material.dart';
import '../models/cuenta_model.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';
import '../widgets/auth_wrapper.dart';

class AccountScreen extends StatelessWidget {
  final CuentaModel? cuenta;
  
  const AccountScreen({super.key, required this.cuenta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2C3E50),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2C3E50),
        title: const Text(
          'Mi Cuenta',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Información del usuario
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFF2C3E50),
                        child: Text(
                          (cuenta?.nombreUsuario.split(' ').map((e) => e[0]).join() ?? 'U'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cuenta?.nombreUsuario ?? 'Usuario',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Cuenta Premium',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoRow('ID de cuenta', cuenta?.id.substring(0, 8) ?? 'N/A'),
                  _buildInfoRow('Saldo principal', '\$${(cuenta?.saldoPrincipal ?? 0).toStringAsFixed(2)}'),
                  _buildInfoRow('Ahorros', '\$${(cuenta?.saldoAhorros ?? 0).toStringAsFixed(2)}'),
                  _buildInfoRow('Total disponible', '\$${(cuenta?.saldoTotal ?? 0).toStringAsFixed(2)}'),
                  _buildInfoRow('Última actualización', _formatDate(cuenta?.ultimaActualizacion)),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Opciones de cuenta
            _buildOptionCard(Icons.security, 'Seguridad', 'Cambiar PIN, biometría'),
            _buildOptionCard(Icons.credit_card, 'Métodos de pago', 'Tarjetas y cuentas'),
            _buildOptionCard(Icons.notifications, 'Notificaciones', 'Configurar alertas'),
            _buildOptionCard(Icons.help, 'Soporte', 'Contactar ayuda'),
            
            const SizedBox(height: 30),
            
            // Botón de cerrar sesión
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF2C3E50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF2C3E50)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          // TODO: Implementar funcionalidad
        },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton.icon(
        onPressed: () => _handleLogout(context),
        icon: const Icon(Icons.logout_rounded),
        label: const Text('Cerrar Sesión'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: AppColors.pureWhite,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cerrar Sesión'),
          content: const Text('¿Estás seguro que deseas cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.pureWhite,
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await AuthService.logout();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}
