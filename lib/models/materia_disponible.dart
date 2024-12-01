class MateriaDisponible {
  final String codigo;
  final String nombre;
  final String horario;
  final String aula;
  final String ubicacion;

  MateriaDisponible({
    required this.codigo,
    required this.nombre,
    required this.horario,
    required this.aula,
    required this.ubicacion,
  });

  factory MateriaDisponible.fromJson(Map<String, dynamic> json) {
    return MateriaDisponible(
      codigo: json['codigo'],
      nombre: json['nombre'],
      horario: json['horario'],
      aula: json['aula'],
      ubicacion: json['ubicacion'],
    );
  }
}