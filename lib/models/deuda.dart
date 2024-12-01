class Deuda {
  final int id;
  final int usuarioId;
  final double monto;
  final bool pagada;
  final DateTime fechaActualizacion;

  Deuda({
    required this.id,
    required this.usuarioId,
    required this.monto,
    required this.pagada,
    required this.fechaActualizacion,
  });

  factory Deuda.fromJson(Map<String, dynamic> json) {
    return Deuda(
      id: json['id'],
      usuarioId: json['usuarioId'],
      monto: (json['monto'] as num).toDouble(),
      pagada: json['pagada'],
      fechaActualizacion: DateTime.parse(json['fechaActualizacion']),
    );
  }
}
