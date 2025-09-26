class EventType {
  final int id;
  final String nombre;

  EventType({required this.id, required this.nombre});

  factory EventType.fromJson(Map<String, dynamic> json) {
    return EventType(
      id: json['categoria_id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}
