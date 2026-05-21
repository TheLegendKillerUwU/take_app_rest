class Habitacion {
  final int id;
  final String numero;
  final String tipo;
  final String descripcion;
  final double precio;
  final String? imagenUrl;
  final String? imagenUrlCompleta;
  final bool disponible;

  Habitacion({
    required this.id,
    required this.numero,
    required this.tipo,
    required this.descripcion,
    required this.precio,
    required this.disponible,
    this.imagenUrl,
    this.imagenUrlCompleta,
  });

  factory Habitacion.fromJson(Map<String, dynamic> json) {
    return Habitacion(
      id: (json['id'] as num).toInt(),
      numero: json['numero']?.toString() ?? '',
      tipo: json['tipo']?.toString() ?? '',
      descripcion: json['descripcion']?.toString() ?? '',
      precio: double.tryParse(json['precio'].toString()) ?? 0,
      imagenUrl: json['imagenUrl']?.toString(),
      imagenUrlCompleta: json['imagenUrlCompleta']?.toString(),
      disponible: json['disponible'] == true,
    );
  }
}
