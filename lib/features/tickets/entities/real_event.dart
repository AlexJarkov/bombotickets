class RealEvent {
  final int eventoId;
  final String nombre;
  final String fecha;
  final String lugar;
  final String ciudad;
  final String? imagen;
  final int maxTickets;
  final EventCategory categoria;
  final EventOrganizer organizador;

  RealEvent({
    required this.eventoId,
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.ciudad,
    this.imagen,
    required this.maxTickets,
    required this.categoria,
    required this.organizador,
  });

  factory RealEvent.fromJson(Map<String, dynamic> json) {
    return RealEvent(
      eventoId: json['evento_id'] as int,
      nombre: json['nombre'] as String,
      fecha: json['fecha'] as String,
      lugar: json['lugar'] as String,
      ciudad: json['ciudad'] as String,
      imagen: json['imagen'] as String?,
      maxTickets: json['max_tickets'] as int,
      categoria: EventCategory.fromJson(
        json['categoria'] as Map<String, dynamic>,
      ),
      organizador: EventOrganizer.fromJson(
        json['organizador'] as Map<String, dynamic>,
      ),
    );
  }
}

class EventCategory {
  final int categoriaId;
  final String nombre;

  EventCategory({required this.categoriaId, required this.nombre});

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      categoriaId: json['categoria_id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

class EventOrganizer {
  final int organizadorId;
  final String nombre;

  EventOrganizer({required this.organizadorId, required this.nombre});

  factory EventOrganizer.fromJson(Map<String, dynamic> json) {
    return EventOrganizer(
      organizadorId: json['organizador_id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}
