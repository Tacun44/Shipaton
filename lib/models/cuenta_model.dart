class CuentaModel {
  final String id;
  final String nombreUsuario;
  final double saldoPrincipal;
  final double saldoAhorros;
  final double limiteTarjeta;
  final double saldoUtilizado;
  final List<MovimientoModel> ultimosMovimientos;
  final DateTime ultimaActualizacion;

  CuentaModel({
    required this.id,
    required this.nombreUsuario,
    required this.saldoPrincipal,
    required this.saldoAhorros,
    required this.limiteTarjeta,
    required this.saldoUtilizado,
    required this.ultimosMovimientos,
    required this.ultimaActualizacion,
  });

  // Saldo disponible en tarjeta
  double get saldoDisponibleTarjeta => limiteTarjeta - saldoUtilizado;

  // Saldo total
  double get saldoTotal => saldoPrincipal + saldoAhorros;

  factory CuentaModel.fromJson(Map<String, dynamic> json) {
    return CuentaModel(
      id: json['id'],
      nombreUsuario: json['nombre_usuario'],
      saldoPrincipal: (json['saldo_principal'] ?? 0).toDouble(),
      saldoAhorros: (json['saldo_ahorros'] ?? 0).toDouble(),
      limiteTarjeta: (json['limite_tarjeta'] ?? 0).toDouble(),
      saldoUtilizado: (json['saldo_utilizado'] ?? 0).toDouble(),
      ultimosMovimientos: [],
      ultimaActualizacion: DateTime.parse(json['updated_at']),
    );
  }
}

class MovimientoModel {
  final String id;
  final String descripcion;
  final double monto;
  final TipoMovimiento tipo;
  final DateTime fecha;
  final String? categoria;

  MovimientoModel({
    required this.id,
    required this.descripcion,
    required this.monto,
    required this.tipo,
    required this.fecha,
    this.categoria,
  });

  factory MovimientoModel.fromJson(Map<String, dynamic> json) {
    return MovimientoModel(
      id: json['id'],
      descripcion: json['descripcion'],
      monto: (json['monto']).toDouble(),
      tipo: TipoMovimiento.values.firstWhere(
        (e) => e.toString().split('.').last == json['tipo'],
      ),
      fecha: DateTime.parse(json['fecha']),
      categoria: json['categoria'],
    );
  }
}

enum TipoMovimiento {
  ingreso,
  gasto,
  transferencia,
  pago,
}
