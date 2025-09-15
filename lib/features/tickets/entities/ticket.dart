import 'package:flutter/material.dart';

enum TicketStatus { activo, usado, vendido }

extension TicketStatusX on TicketStatus {
  String get label {
    switch (this) {
      case TicketStatus.activo:
        return 'Activo';
      case TicketStatus.usado:
        return 'Usado';
      case TicketStatus.vendido:
        return 'Vendido';
    }
  }

  Color get color {
    switch (this) {
      case TicketStatus.activo:
        return Colors.green;
      case TicketStatus.usado:
        return Colors.grey;
      case TicketStatus.vendido:
        return Colors.orange;
    }
  }
}

class Ticket {
  final String id;
  final String eventName;
  final String imageAsset;
  final TicketStatus status;
  final String? qrAsset; // imagen QR local para demo
  final String? qrData; // futuro: dato para generar QR

  const Ticket({
    required this.id,
    required this.eventName,
    required this.imageAsset,
    required this.status,
    this.qrAsset,
    this.qrData,
  });
}

// Nueva clase para eventos disponibles para compra
class EventTicket {
  final String id;
  final String title;
  final String artist;
  final String venue;
  final DateTime date;
  final int price; // En pesos chilenos
  final int originalPrice;
  final String imageUrl;
  final String category;
  final int availableTickets;
  final bool isResale; // true si es reventa

  const EventTicket({
    required this.id,
    required this.title,
    required this.artist,
    required this.venue,
    required this.date,
    required this.price,
    required this.originalPrice,
    required this.imageUrl,
    required this.category,
    required this.availableTickets,
    required this.isResale,
  });

  bool get hasDiscount => price < originalPrice;
  int get discountPercentage =>
      hasDiscount ? ((1 - (price / originalPrice)) * 100).round() : 0;
}

// Nueva clase para mis tickets
class MyTicket {
  final String id;
  final String eventTitle;
  final String venue;
  final DateTime date;
  final TicketStatus status;
  final int purchasePrice;
  final String qrData;
  final String seatInfo;

  const MyTicket({
    required this.id,
    required this.eventTitle,
    required this.venue,
    required this.date,
    required this.status,
    required this.purchasePrice,
    required this.qrData,
    required this.seatInfo,
  });

  factory MyTicket.fromJson(Map<String, dynamic> json) {
    return MyTicket(
      id: json['id'] as String,
      eventTitle: json['eventTitle'] as String,
      venue: json['venue'] as String,
      date: DateTime.parse(json['date'] as String),
      status: TicketStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => TicketStatus.activo,
      ),
      purchasePrice: json['purchasePrice'] as int,
      qrData: json['qrData'] as String,
      seatInfo: json['seatInfo'] as String,
    );
  }

  bool get canSell =>
      status == TicketStatus.activo && date.isAfter(DateTime.now());
  bool get isExpired => date.isBefore(DateTime.now());
}

// Enums para estados de ofertas
enum OfferStatus { publicada, vendida, cancelada }

// Nueva clase para ofertas de marketplace (mis tickets en venta)
class MarketplaceOffer {
  final int id;
  final double precioOfertado;
  final OfferStatus statusOferta;
  final DateTime fechaOferta;
  final DateTime? fechaRespuesta;
  final UserOfertante userOfertante;
  final TicketInfo ticketOfertado;

  const MarketplaceOffer({
    required this.id,
    required this.precioOfertado,
    required this.statusOferta,
    required this.fechaOferta,
    this.fechaRespuesta,
    required this.userOfertante,
    required this.ticketOfertado,
  });

  factory MarketplaceOffer.fromJson(Map<String, dynamic> json) {
    return MarketplaceOffer(
      id: json['id'] as int,
      precioOfertado: (json['precio_ofertado'] as num).toDouble(),
      statusOferta: _parseOfferStatus(json['status_oferta'] as String),
      fechaOferta: DateTime.parse(json['fecha_oferta'] as String),
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.parse(json['fecha_respuesta'] as String)
          : null,
      userOfertante: UserOfertante.fromJson(
        json['user_ofertante'] as Map<String, dynamic>,
      ),
      ticketOfertado: TicketInfo.fromJson(
        json['ticket_ofertado'] as Map<String, dynamic>,
      ),
    );
  }

  // Nuevo método para parsear la respuesta de la API de mis ventas
  factory MarketplaceOffer.fromApiResponse(Map<String, dynamic> json) {
    return MarketplaceOffer(
      id: json['id'] as int,
      precioOfertado: (json['precio'] as num).toDouble(),
      statusOferta: _parseOfferStatus(json['estado'] as String),
      fechaOferta:
          DateTime.now(), // La API no devuelve fecha, usar actual por ahora
      fechaRespuesta: null, // La API no devuelve esta fecha
      userOfertante: UserOfertante(
        id: 0, // No disponible en la respuesta
        nombres: 'Usuario', // No disponible en la respuesta
        apellidoP: '', // No disponible en la respuesta
        apellidoM: '', // No disponible en la respuesta
        email: '', // No disponible en la respuesta
        verificado: false, // No disponible en la respuesta
        staff: false, // No disponible en la respuesta
      ),
      ticketOfertado: TicketInfo(
        id: json['id'] as int,
        token: '', // No disponible en la respuesta
        evento: EventInfo(
          eventoId: 0, // No disponible en la respuesta
          nombre: json['eventoNombre'] as String,
          fecha: json['eventoFecha'] as String? ?? '',
          lugar: json['eventoLugar'] as String? ?? '',
          ciudad: '', // No disponible en la respuesta
          imagen: '', // No disponible en la respuesta
          maxTickets: 0, // No disponible en la respuesta
          categoria: CategoryInfo(categoriaId: 0, nombre: ''), // No disponible
          organizador: OrganizerInfo(
            organizadorId: 0,
            nombre: '',
          ), // No disponible
        ),
        zona: ZoneInfo(
          zonaId: 0, // No disponible en la respuesta
          nombre: json['zonaNombre'] as String,
          precio: (json['precio'] as num).toInt(),
          maxTicketsZonas: 0, // No disponible en la respuesta
        ),
        qrCodeUrl: '', // No disponible en la respuesta
        status: json['estado'] as String,
      ),
    );
  }

  static OfferStatus _parseOfferStatus(String status) {
    switch (status.toUpperCase()) {
      case 'PUBLICADA':
        return OfferStatus.publicada;
      case 'VENDIDA':
        return OfferStatus.vendida;
      case 'CANCELADA':
        return OfferStatus.cancelada;
      default:
        return OfferStatus.publicada;
    }
  }

  bool get isActive => statusOferta == OfferStatus.publicada;
  bool get isSold => statusOferta == OfferStatus.vendida;
  bool get isCancelled => statusOferta == OfferStatus.cancelada;
}

// Información detallada del ticket en oferta
class TicketInfo {
  final int id;
  final String token;
  final EventInfo evento;
  final ZoneInfo zona;
  final String qrCodeUrl;
  final String status;

  const TicketInfo({
    required this.id,
    required this.token,
    required this.evento,
    required this.zona,
    required this.qrCodeUrl,
    required this.status,
  });

  factory TicketInfo.fromJson(Map<String, dynamic> json) {
    return TicketInfo(
      id: json['id'] as int,
      token: json['token'] as String,
      evento: EventInfo.fromJson(json['evento'] as Map<String, dynamic>),
      zona: ZoneInfo.fromJson(json['zona'] as Map<String, dynamic>),
      qrCodeUrl: json['qrCodeUrl'] as String,
      status: json['status'] as String,
    );
  }
}

// Información del evento
class EventInfo {
  final int eventoId;
  final String nombre;
  final String fecha;
  final String lugar;
  final String ciudad;
  final String imagen;
  final int maxTickets;
  final CategoryInfo categoria;
  final OrganizerInfo organizador;

  const EventInfo({
    required this.eventoId,
    required this.nombre,
    required this.fecha,
    required this.lugar,
    required this.ciudad,
    required this.imagen,
    required this.maxTickets,
    required this.categoria,
    required this.organizador,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      eventoId: json['evento_id'] as int,
      nombre: json['nombre'] as String,
      fecha: json['fecha'] as String,
      lugar: json['lugar'] as String,
      ciudad: json['ciudad'] as String,
      imagen: json['imagen'] as String,
      maxTickets: json['max_tickets'] as int,
      categoria: CategoryInfo.fromJson(
        json['categoria'] as Map<String, dynamic>,
      ),
      organizador: OrganizerInfo.fromJson(
        json['organizador'] as Map<String, dynamic>,
      ),
    );
  }

  DateTime get fechaDateTime {
    final parts = fecha.split('-');
    return DateTime(
      int.parse(parts[2]), // año
      int.parse(parts[1]), // mes
      int.parse(parts[0]), // día
    );
  }
}

// Información de la zona
class ZoneInfo {
  final int zonaId;
  final String nombre;
  final int precio;
  final int maxTicketsZonas;

  const ZoneInfo({
    required this.zonaId,
    required this.nombre,
    required this.precio,
    required this.maxTicketsZonas,
  });

  factory ZoneInfo.fromJson(Map<String, dynamic> json) {
    return ZoneInfo(
      zonaId: json['zona_id'] as int,
      nombre: json['nombre'] as String,
      precio: json['precio'] as int,
      maxTicketsZonas: json['max_tickets_zonas'] as int,
    );
  }
}

// Información de categoría
class CategoryInfo {
  final int categoriaId;
  final String nombre;

  const CategoryInfo({required this.categoriaId, required this.nombre});

  factory CategoryInfo.fromJson(Map<String, dynamic> json) {
    return CategoryInfo(
      categoriaId: json['categoria_id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

// Información del organizador
class OrganizerInfo {
  final int organizadorId;
  final String nombre;

  const OrganizerInfo({required this.organizadorId, required this.nombre});

  factory OrganizerInfo.fromJson(Map<String, dynamic> json) {
    return OrganizerInfo(
      organizadorId: json['organizador_id'] as int,
      nombre: json['nombre'] as String,
    );
  }
}

// Nueva entidad para Zonas
class Zone {
  final int zonaId;
  final String nombre;
  final int precio;
  final EventInfo evento;
  final int maxTicketsZonas;

  const Zone({
    required this.zonaId,
    required this.nombre,
    required this.precio,
    required this.evento,
    required this.maxTicketsZonas,
  });

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      zonaId: json['zona_id'] as int,
      nombre: json['nombre'] as String,
      precio: json['precio'] as int,
      evento: EventInfo.fromJson(json['evento'] as Map<String, dynamic>),
      maxTicketsZonas: json['max_tickets_zonas'] as int,
    );
  }
}

// Información del usuario ofertante
class UserOfertante {
  final int id;
  final String nombres;
  final String apellidoP;
  final String apellidoM;
  final String email;
  final bool verificado;
  final String? numeroCuenta;
  final String? nombreBanca;
  final String? imagen;
  final String? descripcion;
  final String? telefono;
  final String? ci;
  final bool staff;

  const UserOfertante({
    required this.id,
    required this.nombres,
    required this.apellidoP,
    required this.apellidoM,
    required this.email,
    required this.verificado,
    this.numeroCuenta,
    this.nombreBanca,
    this.imagen,
    this.descripcion,
    this.telefono,
    this.ci,
    required this.staff,
  });

  factory UserOfertante.fromJson(Map<String, dynamic> json) {
    return UserOfertante(
      id: json['id'] as int,
      nombres: json['nombres'] as String,
      apellidoP: json['apellidoP'] as String,
      apellidoM: json['apellidoM'] as String,
      email: json['email'] as String,
      verificado: json['verificado'] as bool,
      numeroCuenta: json['numeroCuenta'] as String?,
      nombreBanca: json['nombreBanca'] as String?,
      imagen: json['imagen'] as String?,
      descripcion: json['descripcion'] as String?,
      telefono: json['telefono'] as String?,
      ci: json['ci'] as String?,
      staff: json['staff'] as bool,
    );
  }
}

// Entidad para las publicaciones del marketplace (respuesta del servidor)
class MarketplacePublication {
  final int id;
  final int usuarioId;
  final String usuarioEmail;
  final double precioUnitario;
  final bool aceptarOfertas;
  final int estado;
  final DateTime fechaAlta;
  final List<int> ticketsOfertadosIds;

  const MarketplacePublication({
    required this.id,
    required this.usuarioId,
    required this.usuarioEmail,
    required this.precioUnitario,
    required this.aceptarOfertas,
    required this.estado,
    required this.fechaAlta,
    required this.ticketsOfertadosIds,
  });

  factory MarketplacePublication.fromJson(Map<String, dynamic> json) {
    return MarketplacePublication(
      id: json['id'] as int,
      usuarioId: json['usuarioId'] as int,
      usuarioEmail: json['usuarioEmail'] as String,
      precioUnitario: (json['precioUnitario'] as num).toDouble(),
      aceptarOfertas: json['aceptarOfertas'] as bool,
      estado: json['estado'] as int,
      fechaAlta: DateTime.parse(json['fechaAlta'] as String),
      ticketsOfertadosIds: (json['ticketsOfertadosIds'] as List<dynamic>)
          .map((id) => id as int)
          .toList(),
    );
  }

  // Convertir a MarketplaceOffer para compatibilidad con la UI
  MarketplaceOffer toMarketplaceOffer({
    required String eventName,
    required String zoneName,
  }) {
    return MarketplaceOffer(
      id: id,
      precioOfertado: precioUnitario,
      statusOferta: estado == 1 ? OfferStatus.publicada : OfferStatus.cancelada,
      fechaOferta: fechaAlta,
      fechaRespuesta: null,
      userOfertante: UserOfertante(
        id: usuarioId,
        nombres: usuarioEmail
            .split('@')
            .first, // Usar parte del email como nombre temporal
        apellidoP: '',
        apellidoM: '',
        email: usuarioEmail,
        verificado: false,
        telefono: null,
        ci: null,
        staff: false,
      ),
      ticketOfertado: TicketInfo(
        id: ticketsOfertadosIds.isNotEmpty ? ticketsOfertadosIds.first : 0,
        token: 'ticket_${ticketsOfertadosIds.first}',
        evento: EventInfo(
          eventoId: 0, // No disponible en la respuesta
          nombre: eventName,
          fecha: fechaAlta
              .toString()
              .split(' ')
              .first, // Usar fecha de alta como temporal
          lugar: 'Lugar no disponible',
          ciudad: 'Ciudad no disponible',
          imagen: 'imagen_default.jpg',
          maxTickets: 100,
          categoria: CategoryInfo(categoriaId: 1, nombre: 'General'),
          organizador: OrganizerInfo(organizadorId: 1, nombre: 'Organizador'),
        ),
        zona: ZoneInfo(
          zonaId: 1,
          nombre: zoneName,
          precio: precioUnitario.toInt(),
          maxTicketsZonas: ticketsOfertadosIds.length,
        ),
        qrCodeUrl: 'qr_placeholder.png',
        status: 'ACTIVO',
      ),
    );
  }

  bool get isActive => estado == 1;
  int get ticketCount => ticketsOfertadosIds.length;
}
