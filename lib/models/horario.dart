class Horario {
  final int id;
  final int usuarioId;
  final String materia;
  final String aula;
  final DateTime fechaHora;
  final String ubicacion;

  Horario({
    required this.id,
    required this.usuarioId,
    required this.materia,
    required this.aula,
    required this.fechaHora,
    required this.ubicacion,
  });

  factory Horario.fromJson(Map<String, dynamic> json) {
    return Horario(
      id: json['id'],
      usuarioId: json['usuarioId'],
      materia: json['materia'],
      aula: json['aula'],
      fechaHora: DateTime.parse(json['fechaHora']),
      ubicacion: json['ubicacion'],
    );
  }
}