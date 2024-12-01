class Preseleccion {
  final String codigo;
  final String nombre;
  final String aula;
  final String ubicacion;
  final bool confirmada;

  Preseleccion({
    required this.codigo,
    required this.nombre,
    required this.aula,
    required this.ubicacion,
    required this.confirmada,
  });

  factory Preseleccion.fromJson(Map<String, dynamic> json) {
    return Preseleccion(
      codigo: json['codigo'],
      nombre: json['nombre'],
      aula: json['aula'],
      ubicacion: json['ubicacion'],
      confirmada: json['confirmada'],
    );
  }
}