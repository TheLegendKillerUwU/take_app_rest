class Reserva {
  final int id;
  final int habitacionId;
  final String habitacionNumero;
  final String habitacionTipo;
  final String? habitacionImagenUrl;
  final DateTime fechaEntrada;
  final DateTime fechaSalida;
  final String estado;
  final double total;
  final int adultos;
  final int ninos;

  Reserva({
    required this.id,
    required this.habitacionId,
    required this.habitacionNumero,
    required this.habitacionTipo,
    required this.fechaEntrada,
    required this.fechaSalida,
    required this.estado,
    required this.total,
    required this.adultos,
    required this.ninos,
    this.habitacionImagenUrl,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: (json['id'] as num).toInt(),
      habitacionId: (json['habitacionId'] as num).toInt(),
      habitacionNumero: json['habitacionNumero']?.toString() ?? '',
      habitacionTipo: json['habitacionTipo']?.toString() ?? '',
      habitacionImagenUrl: json['habitacionImagenUrl']?.toString(),
      fechaEntrada: DateTime.parse(json['fechaEntrada'].toString()),
      fechaSalida: DateTime.parse(json['fechaSalida'].toString()),
      estado: json['estado']?.toString() ?? 'PENDIENTE',
      total: double.tryParse(json['total'].toString()) ?? 0,
      adultos: (json['adultos'] as num?)?.toInt() ?? 1,
      ninos: (json['ninos'] as num?)?.toInt() ?? 0,
    );
  }
}
