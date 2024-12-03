class Solicitud {
  final int id;
  final int usuarioId;
  final String tipo;
  final String descripcion;
  final String estado;
  final DateTime fechaSolicitud;
  final DateTime? fechaRespuesta;
  final String? respuesta;

  Solicitud({
    required this.id,
    required this.usuarioId,
    required this.tipo,
    required this.descripcion,
    required this.estado,
    required this.fechaSolicitud,
    this.fechaRespuesta,
    this.respuesta,
  });

  factory Solicitud.fromJson(Map<String, dynamic> json) {
    return Solicitud(
      id: json['id'],
      usuarioId: json['usuarioId'],
      tipo: json['tipo'],
      descripcion: json['descripcion'],
      estado: json['estado'],
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      fechaRespuesta: json['fechaRespuesta'] != null 
          ? DateTime.parse(json['fechaRespuesta'])
          : null,
      respuesta: json['respuesta'],
    );
  }
}