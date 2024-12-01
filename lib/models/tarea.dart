class Tarea {
  final int id;
  final int usuarioId;
  final String titulo;
  final String descripcion;
  final DateTime fechaVencimiento;
  final bool completada;

  Tarea({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.fechaVencimiento,
    required this.completada,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      usuarioId: json['usuarioId'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaVencimiento: DateTime.parse(json['fechaVencimiento']),
      completada: json['completada'],
    );
  }
}
