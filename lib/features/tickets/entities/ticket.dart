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
