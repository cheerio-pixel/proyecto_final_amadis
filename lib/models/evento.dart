class Evento {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fechaEvento;
  final String lugar;
  final String coordenadas;

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaEvento,
    required this.lugar,
    required this.coordenadas,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      fechaEvento: DateTime.parse(json['fechaEvento']),
      lugar: json['lugar'],
      coordenadas: json['coordenadas'],
    );
  }
}