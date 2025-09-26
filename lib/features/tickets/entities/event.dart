class Event {
  final int id;
  final String nombre;
  final String descripcion;
  final String fecha;
  final String hora;
  final String lugar;
  final String? imagen;
  final int tipoEventoId;
  final double precioBase;
  final int capacidadTotal;
  final int entradasDisponibles;

  Event({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.lugar,
    this.imagen,
    required this.tipoEventoId,
    required this.precioBase,
    required this.capacidadTotal,
    required this.entradasDisponibles,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
      fecha: json['fecha'] as String,
      hora: json['hora'] as String,
      lugar: json['lugar'] as String,
      imagen: json['imagen'] as String?,
      tipoEventoId: json['tipoEventoId'] as int,
      precioBase: (json['precioBase'] as num).toDouble(),
      capacidadTotal: json['capacidadTotal'] as int,
      entradasDisponibles: json['entradasDisponibles'] as int,
    );
  }

  bool get isAvailable => entradasDisponibles > 0;
}
